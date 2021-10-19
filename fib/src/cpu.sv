`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/11 14:51:07
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
    output logic [31:0] pc_
    );

    // pc
    logic [31:0] pcnext;
    flop pc(.clk(clk), .rstn(rstn), .data(pcnext), .q(pc_));

    initial begin
        pc_ = 32'b0;
    end

    logic [31:0] instr; // todo I-Memory
    logic [6:0] funct7;
    logic [2:0] funct3;
    logic [6:0] opcode;
    logic [4:0] rs0, rs1, rd;
    assign funct7 = instr[31:25];
    assign funct3 = instr[14:12];
    assign opcode = instr[6:0];
    assign rs0 = instr[19:15];
    assign rs1 = instr[24:20];
    assign rd = instr[11:7];

    ram_distributed imem(.clk(clk),
                         .we(1'b0),
                         .addr(pc_[11:2]), // pc[1:0] == 2'b00
                         .di(32'b0),
                         .dout(instr));

    logic [31:0] imm;
    immgen immgen(.instr(instr),
                  .imm(imm));

    logic [31:0] pc4, pcimm;
    assign pc4 = pc_ + 32'b100;
    assign pcimm = pc_ + imm;

    logic [1:0] memtoreg;
    logic memwrite;
    logic [1:0] branchjump; 
    logic [1:0] aluop;
    logic alusrc0;
    logic alusrc1;
    logic regwrite;
    single_cycle_control control(.opcode(opcode), 
                                 .funct3(funct3), 
                                 .funct7(funct7),
                                 .memtoreg(memtoreg), 
                                 .memwrite(memwrite), 
                                 .branchjump(branchjump),
                                 .aluop(aluop),
                                 .alusrc0(alusrc0),
                                 .alusrc1(alusrc1),
                                 .regwrite(regwrite));

    logic [31:0] regwdata;
    logic [31:0] rdata0;
    logic [31:0] rdata1;
    register_file reg_file(.clk(clk),
                           .rstn(rstn),
                           .raddr0(rs0),
                           .raddr1(rs1),
                           .we(regwrite),
                           .waddr(rd),
                           .wdata(regwdata),
                           .rdata0(rdata0),
                           .rdata1(rdata1));

    
    logic [31:0] src0;
    logic [31:0] src1;
    mux2 src0mux2(.data0(rdata0),
                  .data1(32'b0),
                  .s(alusrc0),
                  .data(src0));
    mux2 src1mux2(.data0(rdata1),
                  .data1(imm),
                  .s(alusrc1),
                  .data(src1));

    logic flag;
    logic [31:0] aluresult;
    alu alu(.src0(src0),
            .src1(src1),
            .aluop(aluop),
            .zero(flag),
            .result(aluresult));

    pc_control pc_control(.branchjump(branchjump),
                          .flag(flag),
                          .pc4(pc4),
                          .pcimm(pcimm),
                          .aluresult(aluresult),
                          .pcnext(pcnext));
    
    
    logic [31:0] memrdata; //sign extend?
    ram_distributed dmem(.clk(clk),
                         .we(memwrite),
                         .addr(aluresult),
                         .di(rdata1),
                         .dout(memrdata));
    // todo D-memory
    // memwdata = rdata1
    // memwrite flag
    // memaddr = aluresult

    mux4 regwdatamux4(.data0(aluresult),
                      .data1(memrdata),
                      .data2(pc4),
                      .data3(pcimm),
                      .s(memtoreg),
                      .data(regwdata));

endmodule
