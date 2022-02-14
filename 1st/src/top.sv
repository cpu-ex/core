`default_nettype none
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/25 13:59:06
// Design Name: 
// Module Name: top
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


module top #(CLK_PER_HALF_BIT = 86)(
    input wire clk,
    input wire clk_uart,
    input wire rstn,
    input wire rxd,
    output wire txd,
    
    // cache
    output logic [31:0] addr_cache,
    output logic [31:0] wdata_cache, 
    input wire [31:0] rdata_cache, 
    output logic write_enable_cache,
    output logic read_enable_cache,
    input wire miss_cache,
    output logic [127:0] vec_wdata_cache,
    input wire [127:0] vec_rdata_cache,
    output logic vec_mode_cache,
    output logic [3:0] vec_mask_cache
    );

    logic full, empty, rd_en, wr_en;
    logic [7:0] rdata, tdata;

    cpu cpu(.clk(clk),
            .rstn(rstn),
            .uart_rx_data(rdata),
            .empty(empty),
            .uart_rd_en(rd_en),
            .uart_tx_data(tdata),
            .full(full),
            .uart_wr_en(wr_en),
            .addr_cache(addr_cache),
            .wdata_cache(wdata_cache),
            .rdata_cache(rdata_cache),
            .write_enable_cache(write_enable_cache),
            .read_enable_cache(read_enable_cache),
            .miss_cache(miss_cache),
            .vec_wdata_cache(vec_wdata_cache),
            .vec_rdata_cache(vec_rdata_cache),
            .vec_mode_cache(vec_mode_cache),
            .vec_mask_cache(vec_mask_cache));

    uart_tx_unit #(CLK_PER_HALF_BIT)tx_unit(.clk(clk),
                                            .clk_uart(clk_uart),
                                            .rstn(rstn),
                                            .txd(txd),
                                            .wr_en(wr_en),
                                            .din(tdata),
                                            .full(full));

    uart_rx_unit #(CLK_PER_HALF_BIT)rx_unit(.clk(clk),
                                            .clk_uart(clk_uart),
                                            .rstn(rstn),
                                            .rxd(rxd),
                                            .rd_en(rd_en),
                                            .dout(rdata),
                                            .empty(empty));

endmodule
`default_nettype wire
