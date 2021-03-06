//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/10 16:24:56
// Design Name: 
// Module Name: alu
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

module alu(
    input wire [31:0] src0,
    input wire [31:0] src1,
    input wire [3:0] aluop, 
    output logic [31:0] result
    );

    logic [4:0] shamt;
    assign shamt = src1[4:0];
    always_comb begin
        (* parallel_case *) unique case (aluop)
            4'b0000: result = $signed(src0) + $signed(src1); // ADD
            4'b0001: result = $signed(src0) - $signed(src1); // SUB
            4'b0010: result = $signed(src0) < $signed(src1) ? 32'b1 : 32'b0; // SLT
            4'b0011: result = src0 ^ src1; // XOR
            4'b0100: result = src0 & src1; // AND
            4'b0101: result = src0 | src1; // OR
            4'b0110: result = src0 << shamt; // SLL
            4'b0111: result = src0 >> shamt; // SLR
            4'b1000: result = $signed(src0) >>> shamt; // SLA
            default: result = 32'b0;
        endcase
    end

endmodule
`default_nettype wire
