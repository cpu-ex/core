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
    logic [31:0] pc4E;
    logic [31:0] pcimmE;
    logic [31:0] pcnextE, pcnextM, pcnextW;
    
    // imem
    logic [31:0] instrF, instrD;
    logic [6:0] opcodeD;
    logic [2:0] funct3D; 
    logic [6:0] funct7D;
    logic [5:0] rs0D, rs0E, rs0M, rs0W;
    logic [5:0] rs1D, rs1E, rs1M, rs1W;
    logic [5:0] rdD, rdE, rdM, rdW;
    
    // control signal
    logic memtoregD, memtoregE, memtoregM, memtoregW;
    logic memwriteD, memwriteE, memwriteM;
    logic memreadD, memreadE, memreadM;
    logic imemwriteD, imemwriteE, imemwriteM;
    logic [1:0] branchjumpD, branchjumpE;
    logic [3:0] aluopD, aluopE;
    logic [3:0] fpuopD, fpuopE;
    logic [1:0] alusrc0D, alusrc0E;
    logic [1:0] alusrc1D, alusrc1E;
    logic regwriteD, regwriteE, regwriteM, regwriteW;
    logic aluorfpuD, aluorfpuE, aluorfpuM, aluorfpuW;

    // imm
    logic [31:0] immD, immE, immM, immW;

    // reg file 
    logic [31:0] rdata0D, rdata0E;
    logic [31:0] rdata1D, rdata1E;
    logic [31:0] regwdataW;

    // alu
    logic [31:0] src0E;
    logic [31:0] src1E;
    logic [31:0] aluresultE, aluresultM;
    logic flagE;

    // fpu
    logic [31:0] fpuresultE, fpuresultM;
    logic [31:0] resultM, resultW; // apuresult or fpuresult

    // data memory && MMIO(uart)
    logic [31:0] memwdataE, memwdataM;
    logic [31:0] memrdataM;
    logic [31:0] memdataM, memdataW;
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

            regwriteE <= 0;
            regwriteM <= 0;
            regwriteW <= 0;

            aluorfpuE <= 0;
            aluorfpuM <= 0;
            aluorfpuW <= 0;

            immE <= 0;
            immM <= 0;
            immW <= 0;

            rdata0E <= 0;

            rdata1E <= 0;

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
                    regwriteE <= regwriteD;
                    aluorfpuE <= aluorfpuD;

                    immE <= immD;

                    rdata0E <= rdata0D;
                    rdata1E <= rdata1D;
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
                    aluorfpuM <= aluorfpuE;

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
    logic rs0flag,rs1flag,rdflag;
    assign opcodeD = instrD[6:0];
    assign funct3D = instrD[14:12];
    assign funct7D = instrD[31:25];
    assign rs0D = {rs0flag,instrD[19:15]};
    assign rs1D = {rs1flag,instrD[24:20]};
    assign rdD = {rdflag,instrD[11:7]};

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
                                   .src0(alusrc0D),
                                   .src1(alusrc1D),
                                   .regwrite(regwriteD),
                                   .aluorfpu(aluorfpuD),
                                   .rs0flag(rs0flag),
                                   .rs1flag(rs1flag),
                                   .rdflag(rdflag));

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
        
    // ----- 3 execute stage -----
    mux4 src0mux4(.data0(rdata0E),
                  .data1(32'b0),
                  .data2(pcE),
                  .data3(32'b0),
                  .s(alusrc0E),
                  .data(src0E));

    mux4 src1mux4(.data0(rdata1E),
                  .data1(32'b100),
                  .data2(immE),
                  .data3(32'b0),
                  .s(alusrc1E),
                  .data(src1E));
    
    // alu
    alu alu(.src0(src0E),
            .src1(src1E),
            .aluop(aluopE),
            .flag(flagE),
            .result(aluresultE));

    // fpu
    fpu fpu(.src0(src0E),
            .src1(src1E),
            .fpuop(fpuopE),
            .result(fpuresultE));

    // next pc
    logic [31:0] pcjalrE;
    assign pc4E = pcE + 32'b100; 
    assign pcimmE = pcE + immE; 
    assign pcjalrE = rdata0E + immE;
    pc_control pc_control(.branchjump(branchjumpE),
                          .flag(flagE),
                          .pc4(pc4E),
                          .pcimm(pcimmE),
                          .pcjalr(pcjalrE),
                          .pcnext(pcnextE));

    assign memwdataE = rdata1E;

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
                        .dout(memrdataM));

    mux2 resultmux2(.data0(aluresultM),
                    .data1(fpuresultM),
                    .s(aluorfpuM),
                    .data(resultM));
    
    // ----- 5 writeback stage -----
    mux2 regwdatamux2(.data0(resultW),
                      .data1(memdataW),
                      .s(memtoregW),
                      .data(regwdataW));

    
endmodule