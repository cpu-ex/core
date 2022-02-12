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
    input wire [1:0] branchjump, // 2'b00 -> pc += 4
                                 // 2'b01 -> branch
                                 // 2'b10 -> pc += (signed)imm (JAL)
                                 // 2'b11 -> pc = rdata0 + (signed)imm (JALR)
    input wire flag,
    input wire [31:0] pc4,   // pc + 4
    input wire [31:0] pcimm, // pc + imm
    input wire [31:0] pcjalr,

    output logic [31:0] pcnext
    );

    always_comb begin
        (* parallel_case *) unique case (branchjump)
            2'b00: pcnext = pc4;
            2'b01: pcnext = (flag == 1'b1 ? pcimm : pc4);
            2'b10: pcnext = pcimm;
            2'b11: pcnext = pcjalr;
        endcase
    end

endmodule
`default_nettype wire
