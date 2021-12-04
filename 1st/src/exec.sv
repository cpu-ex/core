`default_nettype none
`timescale 1ns / 1ps
`include "def.sv"

module exec
   (/* verilator lint_off UNUSED */ input wire clk,
    /* verilator lint_off UNUSED */ input wire rstn,
    /* verilator lint_off UNUSED */ input wire enable,
    output wire fin,

    output logic [5:0] rd,
    output logic regwrite,
    output logic memread,
    output logic branchjump_miss,

    input wire [31:0] rdata0,
    input wire [31:0] rdata1,
    input Inst inst,

    output logic [31:0] pcnext,
    output Inst inst_out,
    output logic [31:0] aluresult,
    output logic [31:0] result,
    output logic [31:0] rdata1_out);

    logic [31:0] src0;
    logic [31:0] src1;

    mux4 src0mux4(.data0(rdata0),
                  .data1(32'b0),
                  .data2(inst.pc),
                  .data3(32'b0),
                  .s(inst.src0),
                  .data(src0));

    mux4 src1mux4(.data0(rdata1),
                  .data1(32'b100),
                  .data2(inst.imm),
                  .data3(32'b0),
                  .s(inst.src1),
                  .data(src1));

    // alu
    logic [31:0] aluresult_;
    logic flag;
    alu alu(.src0(src0),
            .src1(src1),
            .aluop(inst.aluop),
            .flag(flag),
            .result(aluresult_));

    // fpu
    logic [31:0] fpuresult;
    fpu fpu(.clk(clk),
            .rstn(rstn),
            .src0(src0),
            .src1(src1),
            .fpuop(inst.fpuop),
            .result(fpuresult));

    mux2 resulumux2(.data0(aluresult_),
                    .data1(fpuresult),
                    .s(inst.aluorfpu),
                    .data(result));

    wire [31:0] pc4 = inst.pc + 32'b100; 
    wire [31:0] pcimm = inst.pc + inst.imm; 
    wire [31:0] pcjalr = rdata0 + inst.imm;
    pc_control pc_control(.branchjump(inst.branchjump),
                          .flag(flag),
                          .pc4(pc4),
                          .pcimm(pcimm),
                          .pcjalr(pcjalr),
                          .pcnext(pcnext));
    
    assign rd = inst.rd;
    assign regwrite = inst.regwrite;
    assign memread = inst.memread;
    assign branchjump_miss = pcnext != pc4;
    assign aluresult = aluresult_;
    assign inst_out = inst;
    assign rdata1_out = rdata1;
    assign fin = 1'b1;

endmodule
`default_nettype wire
