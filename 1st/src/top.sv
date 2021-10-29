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


module top(
    input wire clk,
    input wire rstn,
    input rxd,
    output txd
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
            .uart_wr_en(wr_en));

    uart_tx_unit tx_unit(.clk(clk),
                         .rstn(rstn),
                         .txd(txd),
                         .wr_en(wr_en),
                         .din(tdata),
                         .full(full));

    uart_rx_unit rx_unit(.clk(clk),
                         .rstn(rstn),
                         .rxd(rxd),
                         .rd_en(rd_en),
                         .dout(rdata),
                         .empty(empty));

endmodule
