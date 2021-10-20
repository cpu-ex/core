`timescale 1ns / 1ps
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


module immgen(
    input wire [31:0] instr,
    output logic [31:0] imm
    );

    // opcode
    parameter LUI    = 7'b0110111;
    parameter AUIPC  = 7'b0010111;
    parameter JAL    = 7'b1101111;
    parameter JALR   = 7'b1100111;
    parameter BRANCH = 7'b1100011;
    parameter LOAD   = 7'b0000011;
    parameter STORE  = 7'b0100011;
    parameter CALCI  = 7'b0010011;
    parameter CALC   = 7'b0110011;
    parameter IO     = 7'b0000000;

    wire [31:0] imm_i, imm_s, imm_b, imm_u, imm_j;
    assign imm_i = {{20{instr[31]}}, instr[31:20]};
    assign imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    assign imm_b = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
    assign imm_u = {instr[31], instr[30:12], 12'b0};
    assign imm_j = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

    always_comb begin
        case (instr[6:0])
            LUI    : imm = imm_u;
            AUIPC  : imm = imm_u;
            JAL    : imm = imm_j;
            JALR   : imm = imm_i;
            BRANCH : imm = imm_b;
            LOAD   : imm = imm_i;
            STORE  : imm = imm_s;
            CALCI  : imm = imm_i;
            CALC   : imm = 32'b0;
            IO     : imm = imm_i;
            default: imm = 32'b0;
        endcase
    end
    
endmodule
