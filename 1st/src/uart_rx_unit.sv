`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/23 13:04:32
// Design Name: 
// Module Name: uart_rx_unit
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


module uart_rx_unit #(CLK_PER_HALF_BIT = 5208) (
                      input wire clk,
                      input wire rstn,
                      input wire rxd,
                      input wire rd_en,
                      output logic [7:0] dout,
                      output wire empty       
                     );
    
    logic [7:0] rdata;
    logic       rdata_ready;
    logic       ferr;

    uart_rx #(CLK_PER_HALF_BIT) rx(.rdata(rdata),
                                   .rdata_ready(rdata_ready),
                                   .ferr(ferr),
                                   .clk(clk),
                                   .rstn(rstn),
                                   .rxd(rxd));
    
    logic full;

    // fifo generator (ip core)
    fifo_generator_0 fifo(
        .clk(clk),            // input wire clk
        .rst(~rstn),          // input wire rst
        .din(rdata),          // input wire [7 : 0] din
        .wr_en(rdata_ready),  // input wire wr_en
        .rd_en(rd_en),        // input wire rd_en
        .dout(dout),          // output wire [7 : 0] dout
        .full(full),          // output wire full
        .empty(empty)         // output wire empty
    );  

    // don't manage error when fifo is empty
endmodule
