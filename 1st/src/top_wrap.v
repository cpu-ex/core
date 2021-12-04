`default_nettype none
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/07 15:17:45
// Design Name: 
// Module Name: top_wrap
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


module top_wrap #(CLK_PER_HALF_BIT = 86)(
    input wire clk,
    input wire clk_uart,
    input wire rstn,
    input wire rxd,
    output wire txd
    );

    top #(CLK_PER_HALF_BIT) top(.clk(clk),
                                .clk_uart(clk_uart),
                                .rstn(rstn),
                                .rxd(rxd),
                                .txd(txd));
                                
endmodule
`default_nettype wire
