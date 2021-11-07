`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/24 23:46:17
// Design Name: 
// Module Name: cpu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module cpu(
    input wire clk,
    input wire rstn,
    // uart_rx_unit
    input wire [7:0] uart_rx_data,
    input wire empty,
    output wire uart_rd_en,
    // uart_tx_unit
    output wire [7:0] uart_tx_data,
    input wire full,
    output wire uart_wr_en
    );   
    
    // pc 
    logic [31:0] pc;
    logic [31:0] pc4, pcimm, pcnext;
    
    logic [31:0] instr;
    logic [6:0] opcode;
    logic [2:0] funct3; 
    logic [6:0] funct7;
    logic [4:0] rs0, rs1, rd;
    
    // control signal
    logic [1:0] memtoreg;
    logic memwrite;
    logic memread;
    logic imemwrite;
    logic [1:0] branchjump;
    logic [3:0] aluop;
    logic [3:0] fpuop;
    logic alusrc0;
    logic alusrc1;
    logic fpusrc0;
    logic regwrite;
    logic fregwrite;
    logic aluorfpu;
    logic wordorbyte;

    // imm
    logic [31:0] imm;

    // reg file 
    logic [31:0] rdata0, rdata1;
    logic [31:0] regwdata;

    // freg file
    logic [31:0] frdata0, frdata1;

    // alu
    logic [31:0] src0, src1, aluresult;
    logic flag;

    // fpu
    logic [31:0] fsrc0, fpuresult;
    logic [31:0] result; // apuresult or fpuresult

     // data memory && MMIO(uart)
     logic [31:0] memwdata, memrdata_word, memrdata_byte, memrdata, memdata;
     assign memrdata_byte = {{24{memrdata_word[31]}},memrdata_word[31:24]}; // big endian
     // assign memrdata_byte = {{24{memrdata_word[7]}},memrdata_word[7:0]}; // little endian
     assign memdata = aluresult[9:0] == 10'b0000000000 ? {24'b0,uart_rx_data}:
                      aluresult[9:0] == 10'b0000000100 ? {31'b0,~empty}:
                      aluresult[9:0] == 10'b0000001000 ? {31'b0,~full}:
                      memrdata;
     assign uart_rd_en = memread && aluresult[9:0] == 10'b0000000000;
     assign uart_wr_en = memwrite && aluresult[9:0] == 10'b0000001100;
     assign uart_tx_data = memwdata[7:0];

    // pc
    flop pc_(.clk(clk),
             .rstn(rstn),
             .data(pcnext),
             .q(pc));

    // imem
    // only execute store word
    ram_distributed_inst imem(.clk(clk), 
                              .we(imemwrite), 
                              .raddr(pc[11:2]),
                              .waddr(aluresult[11:2]),  
                              .di(memwdata),
                              .dout(instr));
    
    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];
    assign rs0 = instr[19:15];
    assign rs1 = instr[24:20];
    assign rd = instr[11:7];

    // controler
    single_cycle_control controler(.opcode(opcode),
                                   .funct3(funct3),
                                   .funct7(funct7),
                                   .memtoreg(memtoreg),
                                   .memwrite(memwrite),
                                   .memread(memread),
                                   .imemwrite(imemwrite),
                                   .branchjump(branchjump),
                                   .aluop(aluop),
                                   .fpuop(fpuop),
                                   .alusrc0(alusrc0),
                                   .alusrc1(alusrc1),
                                   .fpusrc0(fpusrc0),
                                   .regwrite(regwrite),
                                   .fregwrite(fregwrite),
                                   .aluorfpu(aluorfpu),
                                   .wordorbyte(wordorbyte));

    // imm
    immgen immgen(.instr(instr),
                  .imm(imm));

    // reg file
    register_file regfile(.clk(clk),
                          .rstn(rstn),
                          .raddr0(rs0),
                          .raddr1(rs1),
                          .we(regwrite),
                          .waddr(rd),
                          .wdata(regwdata),
                          .rdata0(rdata0),
                          .rdata1(rdata1));
    
    // freg file
    fregister_file fregfile(.clk(clk),
                            .rstn(rstn),
                            .raddr0(rs0),
                            .raddr1(rs1),
                            .we(fregwrite),
                            .waddr(rd),
                            .wdata(regwdata),
                            .rdata0(frdata0),
                            .rdata1(frdata1));
    
    mux2 src0mux2(.data0(rdata0),
                  .data1(32'b0),
                  .s(alusrc0),
                  .data(src0));

    mux2 src1mux2(.data0(rdata1),
                  .data1(imm),
                  .s(alusrc1),
                  .data(src1));

    mux2 fsrc0mux2(.data0(frdata0),
                   .data1(rdata0),
                   .s(fpusrc0),
                   .data(fsrc0));
    
    // alu
    alu alu(.src0(src0),
            .src1(src1),
            .aluop(aluop),
            .flag(flag),
            .result(aluresult));

    // fpu
    fpu fpu(.src0(fsrc0),
            .src1(frdata1),
            .fpuop(fpuop),
            .result(fpuresult));

    // next pc
    assign pc4 = pc + 32'b100; 
    assign pcimm = pc + imm; 
    pc_control pc_control(.branchjump(branchjump),
                          .flag(flag),
                          .pc4(pc4),
                          .pcimm(pcimm),
                          .aluresult(aluresult),
                          .pcnext(pcnext));
    
    mux2 memwdatamux2(.data0(rdata1),
                      .data1(frdata1),
                      .s(aluorfpu),
                      .data(memwdata));

    // dmem
    ram_distributed_data dmem(.clk(clk),
                              .we(memwrite),
                              .raddr(aluresult[11:2]),
                              .waddr(aluresult[11:2]),
                              .di(memwdata),
                              .dout(memrdata_word));

    mux2 resultmux2(.data0(aluresult),
                    .data1(fpuresult),
                    .s(aluorfpu),
                    .data(result));

    mux2 memrdatamux2(.data0(memrdata_word),
                      .data1(memrdata_byte),
                      .s(wordorbyte),
                      .data(memrdata));
    
    mux4 regwdatamux4(.data0(result),
                      .data1(memdata),
                      .data2(pc4),
                      .data3(pcimm),
                      .s(memtoreg),
                      .data(regwdata));

    
endmodule