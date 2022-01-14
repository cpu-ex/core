`default_nettype none
`timescale 1ns / 1ps

module fetch
   (input wire clk,
    input wire rstn,
    input wire enable,
    output wire fin,

    output logic [31:0] imemraddr,
    input wire [31:0] imemrdata,
    input wire branchjump_miss,
    output wire i_jal,
    output wire [31:0] pc_jal,

    input wire [31:0] pc,
    input wire [31:0] pcnext,

    output logic [31:0] pc_out,
    output logic [31:0] instr);

    localparam JAL    = 7'b1101111; // jal 
    logic [31:0] imm_j;

    always_ff @(posedge clk) begin
        if (~rstn) begin
            pc_out <= 32'b0;
        end else begin
            pc_out <= imemraddr;
        end
    end

    // simple decode to avoid jal stall
    assign i_jal = (imemrdata[6:0] == JAL);
    assign imm_j = {{12{imemrdata[31]}}, imemrdata[19:12], imemrdata[20], imemrdata[30:21], 1'b0};
    assign pc_jal = pc_out + imm_j;

    assign imemraddr = (~rstn) ? 32'b0:
                       enable ? (i_jal ? pc_jal : pc) : // ~stall && ~flush
                       branchjump_miss ? pcnext :       // branch jump miss
                       pc_out;                          // otherwise -> stall
    assign instr = imemrdata;
    assign fin = 1'b1;

endmodule
`default_nettype wire
