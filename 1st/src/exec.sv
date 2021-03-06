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
    // branch prediction
    output logic taken,
    output logic update,

    input wire [31:0] rdata0,
    input wire [31:0] rdata1,
    input wire [31:0] rdata2,
    input wire [31:0] rdata3,
    input wire [31:0] rdata4,
    input wire [31:0] rdata5,
    input Inst inst,
    input wire flag,

    output logic [31:0] pcnext,
    output Inst inst_out,
    output logic [31:0] aluresult,
    output logic [31:0] result,
    output logic [31:0] rdata1_out,
    output logic [127:0] vec_data);

    logic [31:0] src0, src1;
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
    alu alu(.src0(src0),
            .src1(src1),
            .aluop(inst.aluop),
            .result(aluresult_));

    // fpu
    logic [31:0] fpuresult;
    logic fpu_fin;
    fpu fpu(.clk(clk),
            .rstn(rstn),
            .src0(rdata0),
            .src1(rdata1),
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
    assign branchjump_miss = inst.branchjump == 2'b01 ? (flag != inst.prediction): // branch
                             inst.branchjump == 2'b11 ? 1'b1: // JALR
                             1'b0;
    assign taken = flag;
    assign update = inst.branchjump == 2'b01; // branch

    assign aluresult = rdata0 + inst.imm; // memaddr
    assign vec_data = {rdata5, rdata4, rdata3, rdata2}; // 5432
    assign inst_out = inst;
    assign rdata1_out = rdata1;
    assign fin = fpu_fin;

endmodule

`default_nettype wire
