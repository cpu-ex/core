`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/15 13:04:26
// Design Name: 
// Module Name: ram_distributed
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


module ram_distributed(
    input clk,
    input we,
    input [9:0] addr,
    input [31:0] di,
    output[31:0] dout 
    );

    (* ram_style = "distributed" *) reg [31:0] ram [1023:0];

    always @(posedge clk) begin
        if (we) begin
            ram[addr] <= di;
        end
    end

    assign dout = ram[addr];
endmodule
