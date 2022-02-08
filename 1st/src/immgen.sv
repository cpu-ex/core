
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/11 17:58:51
// Design Name: 
// Module Name: immgen
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
`default_nettype none
`timescale 1ns / 1ps

module immgen(
    input wire [31:0] instr,
    output logic [31:0] imm
    );

    // opcode
    localparam LUI     = 7'b0110111; 
    localparam AUIPC   = 7'b0010111; 
    localparam JAL     = 7'b1101111;
    localparam JALR    = 7'b1100111; 
    localparam BRANCH  = 7'b1100011; 
    localparam LOAD    = 7'b0000011; 
    localparam STORE   = 7'b0100011;
    localparam CALCI   = 7'b0010011; 
    localparam CALC    = 7'b0110011; 
    localparam FLOAD   = 7'b0000111; 
    localparam FSTORE  = 7'b0100111; 
    localparam F       = 7'b1010011; 
    localparam FBRANCH = 7'b1100001;
    localparam VLW     = 7'b1000000;
    localparam VSW     = 7'b1000010;

    wire [31:0] imm_i, imm_s, imm_b, imm_u, imm_j;
    assign imm_i = {{20{instr[31]}}, instr[31:20]};
    assign imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    assign imm_b = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
    assign imm_u = {instr[31], instr[30:12], 12'b0};
    assign imm_j = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

    always_comb begin
        (* parallel_case *) unique case (instr[6:0])
            LUI    : imm = imm_u;
            AUIPC  : imm = imm_u;
            JAL    : imm = imm_j;
            JALR   : imm = imm_i;
            BRANCH : imm = imm_b;
            LOAD   : imm = imm_i;
            STORE  : imm = imm_s;
            CALCI  : imm = imm_i;
            CALC   : imm = 32'b0;
            FLOAD  : imm = imm_i;
            FSTORE : imm = imm_s;
            F      : imm = 32'b0;
            FBRANCH: imm = imm_b;
            VLW    : imm = imm_i;
            VSW    : imm = imm_i;
            default: imm = 32'b0;
        endcase
    end
    
endmodule
`default_nettype wire
