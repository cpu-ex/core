`default_nettype none
`timescale 1ns / 1ps
`include "def.sv"

module exec
   (input wire clk,
    input wire rstn,
    input wire enable,
    output wire fin,

    output logic [5:0] rd,
    output logic regwrite,
    output logic memread,
    output logic branchjump_miss,

    input wire [31:0] src0,
    input wire [31:0] src1,
    input wire [31:0] rdata0,
    input wire [31:0] rdata1,
    input wire flag,
    input Inst inst,

    output logic [31:0] pcnext,
    output Inst inst_out,
    output logic [31:0] aluresult,
    output logic [31:0] result,
    output logic [31:0] rdata1_out);

    // alu
    logic [31:0] aluresult_;
    alu alu(.src0(src0),
            .src1(src1),
            .aluop(inst.aluop),
            .result(aluresult_));

    // fpu
    logic [31:0] fpuresult;
    logic fpu_fin;
    fpu fpu(.clk(clk),
            .rstn(rstn),
            .src0(src0),
            .src1(src1),
            .fpuop(inst.fpuop),
            .result(fpuresult),
            .fin(fpu_fin));

    mux2 resultmux2(.data0(aluresult_),
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
    assign branchjump_miss = inst.branchjump == 2'b10 ? 1'b0 :  // JAL 
                                                        pcnext != pc4;
    assign aluresult = src0 + src1; // memaddr
    assign inst_out = inst;
    assign rdata1_out = rdata1;
    assign fin = fpu_fin;

endmodule

`default_nettype wire
