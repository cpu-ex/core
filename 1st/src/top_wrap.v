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
    output wire txd,
    // cache
    output wire [31:0] addr_cache,
    output wire [31:0] wdata_cache, 
    input wire [31:0] rdata_cache, 
    output wire write_enable_cache,
    output wire read_enable_cache,
    input wire miss_cache
    );

    top #(CLK_PER_HALF_BIT) top(.clk(clk),
                                .clk_uart(clk_uart),
                                .rstn(rstn),
                                .rxd(rxd),
                                .txd(txd),
                                .addr_cache(addr_cache),
                                .wdata_cache(wdata_cache),
                                .rdata_cache(rdata_cache),
                                .write_enable_cache(write_enable_cache),
                                .read_enable_cache(read_enable_cache),
                                .miss_cache(miss_cache));
                                
endmodule
`default_nettype wire
