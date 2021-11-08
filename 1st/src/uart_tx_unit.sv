`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/23 13:05:20
// Design Name: 
// Module Name: uart_tx_unit
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


module uart_tx_unit #(CLK_PER_HALF_BIT = 86)(
                      input wire clk,
                      input wire clk_uart,
                      input wire rstn,
                      output wire txd,
                      input wire wr_en,
                      input logic [7:0] din,
                      output wire full
                     );

    logic [7:0] sdata;
    logic tx_start;
    logic tx_busy;

    uart_tx #(CLK_PER_HALF_BIT) tx(.sdata(sdata),
                                   .tx_start(tx_start),
                                   .tx_busy(tx_busy),
                                   .txd(txd),
                                   .clk(clk_uart),
                                   .rstn(rstn));
    
    logic rd_en, empty;

    // fifo generator (ip core)
    fifo_generator_4 fifo (
        .rst(~rstn),       // input wire rst
        .wr_clk(clk),      // input wire wr_clk
        .rd_clk(clk_uart), // input wire rd_clk
        .din(din),         // input wire [7 : 0] din
        .wr_en(wr_en),     // input wire wr_en
        .rd_en(rd_en),     // input wire rd_en
        .dout(sdata),      // output wire [7 : 0] dout
        .full(full),       // output wire full
        .empty(empty)      // output wire empty
    );


    logic [1:0] status_read;

    always @(posedge clk_uart) begin
        if (~rstn) begin
            rd_en <= 0;
            tx_start <= 0;
            status_read <= 0;
        end else begin
            //    fifo is not empty 
            // && uart_tx is not sending data
            // -> start sending data in fifo
            if (status_read == 2'b01) begin
                rd_en <= 0;
                tx_start <= 1;
                status_read <= 2'b10;
            end else if (status_read == 2'b10) begin
                rd_en <= 0;
                tx_start <= 0;
                status_read <= 0;
            end else if (~empty && ~tx_busy) begin
                rd_en <= 1;
                tx_start <= 0;
                status_read <= 2'b01;
            end else begin
                rd_en <= 0;
                tx_start <= 0;
                status_read <= 0;
            end
        end
    end

    // don't manage error when fifo is full
endmodule
