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
    
    // DRAM
    output logic [31:0] addr,
    output logic [31:0] wdata, 
    input wire [31:0] rdata_DRAM, 
    output logic write_enable_DRAM,
    output logic read_enable_DRAM,
    // input logic ready;
    input wire miss
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
            .addr(addr),
            .wdata(wdata),
            .rdata(rdata_DRAM),
            .write_enable_DRAM(write_enable_DRAM),
            .read_enable_DRAM(read_enable_DRAM),
            .miss(miss));

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
