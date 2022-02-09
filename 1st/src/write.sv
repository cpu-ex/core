`default_nettype none
`timescale 1ns / 1ps
`include "def.sv"

module write
   (input wire clk,
    input wire rstn,
    input wire enable,
    output wire fin,

    output logic [31:0] regwdata,
    output logic [31:0] regwdata2,
    output logic [31:0] regwdata3,
    output logic [31:0] regwdata4,
    output logic [31:0] regwdata5,
    output logic regwrite,
    output logic vec_regwrite,
    output logic [5:0] rd,
    output logic [5:0] rd2,
    output logic [5:0] rd3,
    output logic [5:0] rd4,
    output logic [5:0] rd5,

    input Inst inst,
    input wire [31:0] regwdata_in,
    input wire [127:0] vec_regwdata_in
   );

    assign regwdata = regwdata_in;
    // 5432
    assign regwdata2 = vec_regwdata_in[31:0];
    assign regwdata3 = vec_regwdata_in[63:32];
    assign regwdata4 = vec_regwdata_in[95:64];
    assign regwdata5 = vec_regwdata_in[127:96];
    assign regwrite = inst.regwrite;
    assign vec_regwrite = inst.vec_regwrite;
    assign rd = inst.rd;
    assign rd2 = inst.reg2;
    assign rd3 = inst.reg3;
    assign rd4 = inst.reg4;
    assign rd5 = inst.reg5;
    assign fin = 1'b1;
endmodule

`default_nettype wire