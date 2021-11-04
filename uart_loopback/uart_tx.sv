`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/17 20:43:17
// Design Name: 
// Module Name: uart_tx
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


`default_nettype none
// 11520000 baud rate
// 100Mhz -> clk_per_half_bit = 4.3
module uart_tx #(CLK_PER_HALF_BIT = 4) (
               input wire [7:0] sdata,
               input wire       tx_start,
               output logic     tx_busy,
               output logic     txd,
               input wire       clk,
               input wire       rstn);
    
	localparam e_clk_halfbit = CLK_PER_HALF_BIT - 1;
	localparam e_clk_bit = CLK_PER_HALF_BIT * 2 - 1;
	
	logic [7:0]                  txbuf;
	logic [3:0]                  status;
	logic [31:0]                 counter;
	
	localparam s_idle = 4'd0;
	localparam s_start_bit = 4'd1;
	localparam s_bit_0 = 4'd2;
	localparam s_bit_1 = 4'd3;
	localparam s_bit_2 = 4'd4;
	localparam s_bit_3 = 4'd5;
	localparam s_bit_4 = 4'd6;
	localparam s_bit_5 = 4'd7;
	localparam s_bit_6 = 4'd8;
	localparam s_bit_7 = 4'd9;
	localparam s_stop_bit = 4'd10;

	always @(posedge clk) begin
		if (~rstn) begin
			counter <= 32'b0;
			status <= s_idle;
			txbuf <= 8'b0;
			tx_busy <= 1'b0;
			txd <= 1'b1;
		end else begin
			if (status == s_idle) begin
				if (tx_start) begin
					counter <= 32'b0;
					status <= s_start_bit;
					txbuf <= sdata;
					tx_busy <= 1'b1;
					txd <= 1'b0;
				end
			end else if (status == s_stop_bit) begin
				if (counter == e_clk_bit) begin
					counter <= 32'b0;
					status <= s_idle;
					tx_busy <= 1'b0;
					txd <= 1'b1;
				end else begin
					counter <= counter + 32'b1;
				end
			end else if (status[0] == 1'b0) begin
				if (counter == e_clk_bit + 32'b1) begin
					counter <= 32'b0;
					status <= status + 4'b1;
					txd <= txbuf[0];
					txbuf <= {1'b1, txbuf[7:1]};
				end else begin
					counter <= counter + 32'b1;
				end
			end else begin // status[0] == 1'b1
				if (counter == e_clk_bit) begin
					counter <= 32'b0;
					status <= status + 4'b1;
					txd <= txbuf[0];
					txbuf <= {1'b1, txbuf[7:1]};
				end else begin
					counter <= counter + 32'b1;
				end
			end
		end
	end
   
endmodule // uart_tx
`default_nettype wire

