`default_nettype none
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
    (*mark_debug="true"*)input wire [1:0] branchjump, // 2'b00 -> pc += 4
                                                      // 2'b01 -> branch
                                                      // 2'b10 -> pc += (signed)imm (JAL)
                                                      // 2'b11 -> pc = rdata0 + (signed)imm (JALR)
    (*mark_debug="true"*)input wire flag,
    (*mark_debug="true"*)input wire [31:0] pc4,   // pc + 4
    (*mark_debug="true"*)input wire [31:0] pcimm, // pc + imm
    (*mark_debug="true"*)input wire [31:0] pcjalr,

    output wire [31:0] pcnext
    );

    assign pcnext = branchjump == 2'b00 ? pc4 :
                    branchjump == 2'b10 ? pcimm :
                    branchjump == 2'b11 ? pcjalr :
                    flag == 1'b1 ? pcimm : 
                    pc4; // (flag == 1'b0)

endmodule
`default_nettype wire
