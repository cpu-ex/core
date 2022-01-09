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
    // DRAM
    output wire [31:0] addr,
    output wire [31:0] wdata, 
    input wire [31:0] rdata, 
    output wire write_enable_DRAM,
    output wire read_enable_DRAM,
    // input wire ready;
    input wire miss
    );

    top #(CLK_PER_HALF_BIT) top(.clk(clk),
                                .clk_uart(clk_uart),
                                .rstn(rstn),
                                .rxd(rxd),
                                .txd(txd),
                                .addr(addr),
                                .wdata(wdata),
                                .rdata_DRAM(rdata),
                                .write_enable_DRAM(write_enable_DRAM),
                                .read_enable_DRAM(read_enable_DRAM),
                                .miss(miss));
                                
endmodule
`default_nettype wire
