`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/11 19:13:06
// Design Name: 
// Module Name: pc_control
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


module pc_control (
    input wire [1:0] branchjump, // 2'b00 -> pc += 4
                                 // 2'b01 -> branch
                                 // 2'b10 -> pc += (signed)imm (JAL)
                                 // 2'b11 -> pc = aluresult (JALR)
    input wire flag,
    input wire [31:0] pc4,   // pc + 4
    input wire [31:0] pcimm, // pc + imm
    input wire [31:0] aluresult,

    output wire [31:0] pcnext
    );

    assign pcnext = branchjump == 2'b00 ? pc4 :
                    branchjump == 2'b10 ? pcimm :
                    branchjump == 2'b11 ? aluresult :
                    flag == 1'b1 ? pcimm : 
                    pc4; // (flag == 1'b0)

endmodule