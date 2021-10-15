`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/12 21:22:58
// Design Name: 
// Module Name: rams_sp
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


module rams_sp(
    input clk,
    input we,
    input [9:0] addr,
    input [31:0] di,
    output reg [31:0] dout
    );

    (* ram_style = "block" *) reg [31:0] ram [1023:0]; // todo ramsize?

    always @(posedge clk) begin
        if (we) begin
            ram[addr] <= di;
        end else begin
            dout <= ram[addr];
        end
    end

endmodule
