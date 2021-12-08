`default_nettype none
`timescale 1ns / 1ps

module fetch
   (input wire clk,
    input wire rstn,
     /* verilator lint_off UNUSED */ input wire enable,
    output wire fin,

    output logic [31:0] imemraddr,
    input wire [31:0] imemrdata,
    input wire branchjump_miss,
    input wire lwstall,

    input wire [31:0] pc,
    input wire [31:0] pcnext,

    output logic [31:0] pc_out,
    output logic [31:0] instr);

    always_ff @(posedge clk) begin
        if (~rstn) begin
            pc_out <= 32'b0;
        end else begin
            pc_out <= imemraddr;
        end
    end

    assign imemraddr = enable ? pc :              // ~stall && ~flush
                       branchjump_miss ? pcnext : // branch jump miss
                       pc_out;                    // otherwise -> stall
    assign instr = imemrdata;
    assign fin = 1'b1;

endmodule
`default_nettype wire
