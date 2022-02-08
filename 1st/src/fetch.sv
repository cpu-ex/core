`default_nettype none
`timescale 1ns / 1ps

module fetch
   (input wire clk,
    input wire rstn,
    input wire enable,
    output wire fin,

    output logic [31:0] imemraddr,
    input wire [31:0] imemrdata,
    input wire [31:0] imemrdata1,
    input wire branchjump_miss,
    output wire [31:0] pc_predicated,
    // branch prediction
    input wire prediction,
    input wire [7:0] pc_xor_global_history,

    input wire [31:0] pc,
    input wire [31:0] pcnext,

    output logic [31:0] pc_out,
    output logic [31:0] instr,
    output logic [31:0] instr1,
    output logic [31:0] pc_xor_global_history_out);

    localparam JAL     = 7'b1101111; // jal 
    localparam BRANCH  = 7'b1100011; // beq, bne, blt, bge
    localparam FBRANCH = 7'b1100001; // bfeq, bfle, bflt

    always_ff @(posedge clk) begin
        if (~rstn) begin
            pc_out <= 32'b0;
            pc_xor_global_history_out <= 8'b0;
        end else begin
            pc_out <= imemraddr;
            pc_xor_global_history_out <= pc_xor_global_history;
        end
    end

    // simple decode to avoid jal stall, branch prediction, 64bit instruction
    wire i_jal    = (imemrdata[6:0] == JAL);
    wire i_branch = (imemrdata[6:0] == BRANCH || imemrdata[6:0] == FBRANCH);
    wire i_64     = (imemrdata[0] == 1'b0);
    wire [31:0] imm_j = {{12{imemrdata[31]}}, imemrdata[19:12], imemrdata[20], imemrdata[30:21], 1'b0};
    wire [31:0] imm_b = {{20{imemrdata[31]}}, imemrdata[7], imemrdata[30:25], imemrdata[11:8], 1'b0};
    wire [31:0] pc_jal    = pc_out + imm_j;
    wire [31:0] pc_branch = pc_out + imm_b;

    assign pc_predicated = i_jal                    ? pc_jal:
                           (i_branch && prediction) ? pc_branch:
                           i_64                     ? pc + 32'b100:
                           pc; 

    assign imemraddr = (~rstn) ? 32'b0:
                       enable  ? pc_predicated :  // ~stall && ~flush
                       branchjump_miss ? pcnext : // branch jump miss
                       pc_out;                    // otherwise -> stall

    assign instr = imemrdata;
    assign instr1 = imemrdata1;
    assign fin = 1'b1;

endmodule
`default_nettype wire
