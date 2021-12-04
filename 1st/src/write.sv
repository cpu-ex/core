`default_nettype none
`timescale 1ns / 1ps
`include "def.sv"

module write
   (/* verilator lint_off UNUSED */ input wire clk,
    /* verilator lint_off UNUSED */ input wire rstn,
    /* verilator lint_off UNUSED */ input wire enable,
    output wire fin,

    output logic [31:0] regwdata,
    output logic regwrite,
    output logic [5:0] rd,

    input Inst inst,
    input wire [31:0] regwdata_in
   );

    assign regwdata = regwdata_in;
    assign regwrite = inst.regwrite;
    assign rd = inst.rd;
    assign fin = 1'b1;
endmodule

`default_nettype wire