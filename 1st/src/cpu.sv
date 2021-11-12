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

    // state
    localparam s_idle      = 3'd0;
    localparam s_fetch     = 3'd1;
    localparam s_decode    = 3'd2;
    localparam s_execute   = 3'd3;
    localparam s_memory    = 3'd4;
    localparam s_writeback = 3'd5;
    logic [2:0] state;
    
    // pc 
    logic [31:0] pcF, pcD, pcE, pcM, pcW;
    logic [31:0] pc4E, pc4W;
    logic [31:0] pcimmE, pcimmW;
    logic [31:0] pcnextE, pcnextM, pcnextW;
    
    // imem
    logic [31:0] instrF, instrD;
    logic [6:0] opcodeD;
    logic [2:0] funct3D; 
    logic [6:0] funct7D;
    logic [4:0] rs0D, rs0E, rs0M, rs0W;
    logic [4:0] rs1D, rs1E, rs1M, rs1W;
    logic [4:0] rdD, rdE, rdM, rdW;
    
    // control signal
    logic [1:0] memtoregD, memtoregE, memtoregM, memtoregW;
    logic memwriteD, memwriteE, memwriteM;
    logic memreadD, memreadE, memreadM;
    logic imemwriteD, imemwriteE, imemwriteM;
    logic [1:0] branchjumpD, branchjumpE;
    logic [3:0] aluopD, aluopE;
    logic [3:0] fpuopD, fpuopE;
    logic alusrc0D, alusrc0E;
    logic alusrc1D, alusrc1E;
    logic fpusrc0D, fpusrc0E;
    logic regwriteD, regwriteE, regwriteM, regwriteW;
    logic fregwriteD, fregwriteE, fregwriteM, fregwriteW;
    logic aluorfpuD, aluorfpuE, aluorfpuM, aluorfpuW;
    logic wordorbyteD, wordorbyteE, wordorbyteM;

    // imm
    logic [31:0] immD, immE, immM, immW;

    // reg file 
    logic [31:0] rdata0D, rdata0E;
    logic [31:0] rdata1D, rdata1E;
    logic [31:0] regwdataW;

    // freg file
    logic [31:0] frdata0D, frdata0E;
    logic [31:0] frdata1D, frdata1E;

    // alu
    logic [31:0] src0E;
    logic [31:0] src1E;
    logic [31:0] aluresultE, aluresultM;
    logic flagE;

    // fpu
    logic [31:0] fsrc0E;
    logic [31:0] fpuresultE, fpuresultM;
    logic [31:0] resultM, resultW; // apuresult or fpuresult

    // data memory && MMIO(uart)
    logic [31:0] memwdataE, memwdataM;
    logic [31:0] memrdata_wordM;
    logic [31:0] memrdata_byteM;
    logic [31:0] memrdataM;
    logic [31:0] memdataM, memdataW;
    assign memrdata_byteM = {{24{memrdata_wordM[31]}},memrdata_wordM[31:24]}; // big endian
    // assign memrdata_byteM = {{24{memrdata_wordM[7]}},memrdata_wordM[7:0]}; // little endian
    assign memdataM = aluresultM[9:0] == 10'b0000000000 ? {24'b0,uart_rx_data}:
                      aluresultM[9:0] == 10'b0000000100 ? {31'b0,~empty}:
                      aluresultM[9:0] == 10'b0000001000 ? {31'b0,~full}:
                      memrdataM;
    assign uart_rd_en = (state == s_memory) && memreadM && aluresultM[9:0] == 10'b0000000000;
    assign uart_wr_en = (state == s_memory) && memwriteM && aluresultM[9:0] == 10'b0000001100;
    assign uart_tx_data = memwdataM[7:0];

    always_ff @(posedge clk) begin
        if (~rstn) begin
            state <= s_idle;
            pcD <= 0;
            pcE <= 0;
            pcM <= 0;
            pcW <= 0;

            pcnextM <= 0;
            pcnextW <= 0;

            instrD <= 0;

            rs0E <= 0;
            rs0M <= 0;
            rs0W <= 0;

            rs1E <= 0;
            rs1M <= 0;
            rs1W <= 0;

            rdE <= 0;
            rdM <= 0;
            rdW <= 0;

            memtoregE <= 0;
            memtoregM <= 0;
            memtoregW <= 0;

            memwriteE <= 0;

            memreadE <= 0;
            memreadM <= 0;

            imemwriteE <= 0;

            branchjumpE <= 0;

            aluopE <= 0;

            fpuopE <= 0;

            alusrc0E <= 0;

            alusrc1E <= 0;

            fpusrc0E <= 0;

            regwriteE <= 0;
            regwriteM <= 0;
            regwriteW <= 0;

            fregwriteE <= 0;
            fregwriteM <= 0;
            fregwriteW <= 0;

            aluorfpuE <= 0;
            aluorfpuM <= 0;
            aluorfpuW <= 0;

            wordorbyteE <= 0;
            wordorbyteM <= 0;

            immE <= 0;
            immM <= 0;
            immW <= 0;

            rdata0E <= 0;

            rdata1E <= 0;

            frdata0E <= 0;

            frdata1E <= 0;

            fpuresultM <= 0;

            resultW <= 0;

            memdataW <= 0;
        end else begin
            case (state)
                s_idle:
                begin
                    state <= s_fetch;
                end
                s_fetch:
                begin
                    state <= s_decode;
                    pcD <= pcF;
                    instrD <= instrF;
                end
                s_decode:
                begin
                    state <= s_execute;
                    pcE <= pcD;

                    rs0E <= rs0D;
                    rs1E <= rs1D;
                    rdE <= rdD;

                    memtoregE <= memtoregD;
                    memwriteE <= memwriteD;
                    memreadE <= memreadD;
                    imemwriteE <= imemwriteD;
                    branchjumpE <= branchjumpD;
                    aluopE <= aluopD;
                    fpuopE <= fpuopD;
                    alusrc0E <= alusrc0D;
                    alusrc1E <= alusrc1D;
                    fpusrc0E <= fpusrc0D;
                    regwriteE <= regwriteD;
                    fregwriteE <= fregwriteD;
                    aluorfpuE <= aluorfpuD;
                    wordorbyteE <= wordorbyteD;

                    immE <= immD;

                    rdata0E <= rdata0D;
                    rdata1E <= rdata1D;
                    frdata0E <= frdata0D;
                    frdata1E <= frdata1D;
                end
                s_execute:
                begin
                    state <= s_memory;
                    pcM <= pcE;
                    pcnextM <= pcnextE;

                    rs0M <= rs0E;
                    rs1M <= rs1E;
                    rdM <= rdE;

                    memtoregM <= memtoregE;
                    memreadM <= memreadE;
                    regwriteM <= regwriteE;
                    fregwriteM <= fregwriteE;
                    aluorfpuM <= aluorfpuE;
                    wordorbyteM <= wordorbyteE;

                    immM <= immE;

                    fpuresultM <= fpuresultE;
                end
                s_memory:
                begin
                    state <= s_writeback;
                    pcW <= pcM;
                    pcnextW <= pcnextM;

                    rs0W <= rs0M;
                    rs1W <= rs1M;
                    rdW <= rdM;

                    memtoregW <= memtoregM;  
                    regwriteW <= regwriteM;
                    fregwriteW <= fregwriteM;
                    aluorfpuW <= aluorfpuM;

                    immW <= immM;

                    resultW <= resultM;
                    memdataW <= memdataM;
                end
                s_writeback:
                begin
                    state <= s_fetch;
                end
            endcase
        end
    end

    // ----- 1 fetch stage -----
    // imem
    // only execute store word
    assign pcF = pcnextW;
    ram_block_inst imem(.clk(clk), 
                        .we(imemwriteM), 
                        .raddr(pcF[11:2]),
                        .waddr(aluresultM[11:2]),  
                        .di(memwdataM),
                        .dout(instrF));
    
    // ----- 2 decode stage -----
    assign opcodeD = instrD[6:0];
    assign funct3D = instrD[14:12];
    assign funct7D = instrD[31:25];
    assign rs0D = instrD[19:15];
    assign rs1D = instrD[24:20];
    assign rdD = instrD[11:7];

    // controler
    single_cycle_control controler(.opcode(opcodeD),
                                   .funct3(funct3D),
                                   .funct7(funct7D),
                                   .memtoreg(memtoregD),
                                   .memwrite(memwriteD),
                                   .memread(memreadD),
                                   .imemwrite(imemwriteD),
                                   .branchjump(branchjumpD),
                                   .aluop(aluopD),
                                   .fpuop(fpuopD),
                                   .alusrc0(alusrc0D),
                                   .alusrc1(alusrc1D),
                                   .fpusrc0(fpusrc0D),
                                   .regwrite(regwriteD),
                                   .fregwrite(fregwriteD),
                                   .aluorfpu(aluorfpuD),
                                   .wordorbyte(wordorbyteD));

    // imm
    immgen immgen(.instr(instrD),
                  .imm(immD));

    // reg file
    register_file regfile(.clk(clk),
                          .rstn(rstn),
                          .raddr0(rs0D),
                          .raddr1(rs1D),
                          .we(regwriteW),
                          .waddr(rdW),
                          .wdata(regwdataW),
                          .rdata0(rdata0D),
                          .rdata1(rdata1D));
    
    // freg file
    fregister_file fregfile(.clk(clk),
                            .rstn(rstn),
                            .raddr0(rs0D),
                            .raddr1(rs1D),
                            .we(fregwriteW),
                            .waddr(rdW),
                            .wdata(regwdataW),
                            .rdata0(frdata0D),
                            .rdata1(frdata1D));
    
    // ----- 3 execute stage -----
    mux2 src0mux2(.data0(rdata0E),
                  .data1(32'b0),
                  .s(alusrc0E),
                  .data(src0E));

    mux2 src1mux2(.data0(rdata1E),
                  .data1(immE),
                  .s(alusrc1E),
                  .data(src1E));

    mux2 fsrc0mux2(.data0(frdata0E),
                   .data1(rdata0E),
                   .s(fpusrc0E),
                   .data(fsrc0E));
    
    // alu
    alu alu(.src0(src0E),
            .src1(src1E),
            .aluop(aluopE),
            .flag(flagE),
            .result(aluresultE));

    // fpu
    fpu fpu(.src0(fsrc0E),
            .src1(frdata1E),
            .fpuop(fpuopE),
            .result(fpuresultE));

    // next pc
    assign pc4E = pcE + 32'b100; 
    assign pcimmE = pcE + immE; 
    pc_control pc_control(.branchjump(branchjumpE),
                          .flag(flagE),
                          .pc4(pc4E),
                          .pcimm(pcimmE),
                          .aluresult(aluresultE),
                          .pcnext(pcnextE));

    mux2 memwdatamux2(.data0(rdata1E),
                      .data1(frdata1E),
                      .s(aluorfpuE),
                      .data(memwdataE));

    // ----- 4 Memory stage -----
    // imem
    assign imemwriteM = imemwriteE;
    assign aluresultM = aluresultE;
    assign memwdataM = memwdataE;
    // dmem
    assign memwriteM = memwriteE;
    ram_block_data dmem(.clk(clk),
                        .we(memwriteM),
                        .addr(aluresultM[11:2]),
                        .di(memwdataM),
                        .dout(memrdata_wordM));

    mux2 resultmux2(.data0(aluresultM),
                    .data1(fpuresultM),
                    .s(aluorfpuM),
                    .data(resultM));

    mux2 memrdatamux2(.data0(memrdata_wordM),
                      .data1(memrdata_byteM),
                      .s(wordorbyteM),
                      .data(memrdataM));
    
    // ----- 5 writeback stage -----
    assign pc4W = pcW + 32'b100;
    assign pcimmW = pcW + immW;
    mux4 regwdatamux4(.data0(resultW),
                      .data1(memdataW),
                      .data2(pc4W),
                      .data3(pcimmW),
                      .s(memtoregW),
                      .data(regwdataW));

    
endmodule