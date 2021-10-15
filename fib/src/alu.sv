`timescale 1ns / 1ps
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

// +, -, slt 
// shift, *, /, &, |, ^ 
module alu(
    input wire [31:0] src0,
    input wire [31:0] src1,
    input wire [1:0] aluop,// 00 -> +
                           // 01 -> -
                           // 10 -> slt 
    output logic zero,
    output logic [31:0] result
    );

    always_comb begin
        case (aluop)
            2'b00: result = $signed(src0) + $signed(src1); 
            2'b01: result = $signed(src0) - $signed(src1);
            2'b10: result = $signed(src0) < $signed(src1) ? 32'b1 : 32'b0;
            default: result = 32'b0;
        endcase
    end

    assign zero = (result == 0);
endmodule
