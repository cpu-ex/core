`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/17 20:55:54
// Design Name: 
// Module Name: uart_rx
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

module uart_rx #(CLK_PER_HALF_BIT = 5208) (
               output logic [7:0] rdata,
               output logic       rdata_ready,
               output logic       ferr,
               input wire         rxd,
               input wire         clk,
               input wire         rstn);

    localparam e_clk_bit = CLK_PER_HALF_BIT * 2 - 1;
    localparam e_stop_bit = (CLK_PER_HALF_BIT*9)/10 - 1;

    logic [7:0]                  rxbuf;
    logic [3:0]                  status;
    logic [31:0]                 counter;
    logic                        next;
   
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
    localparam s_wait_half = 4'd11;

    always @(posedge clk) begin
        if (~rstn) begin
            counter <= 32'b0;
            next <= 1'b0;
        end else begin
			// counter
			// next
            if (counter == e_clk_bit) begin
                counter <= 32'b0;
                next <= 1'b1;
            end else if (counter == CLK_PER_HALF_BIT - 1 && status == s_start_bit ) begin
                counter <= 32'b0;
                next <= 1'b1;
            end else if (counter == e_stop_bit && status == s_wait_half) begin
                counter <= 32'b0;
                next <= 1'b1;
            end else if (status == s_idle && ~rxd) begin
                // start
                counter  <= 32'b0;
                next <= 1'b0;
            end else begin
                counter <= counter + 32'd1;
                next <= 1'b0;
            end
        end
    end

    always @(posedge clk) begin
        if (~rstn) begin
            status <= s_idle;
            rxbuf <= 8'b0;

            rdata <= 8'b0;
            rdata_ready <= 1'b0;
            ferr <= 1'b0;
        end else begin
            rdata_ready <= 1'b0;
            ferr <= 1'b0;

            if (status == s_idle) begin
                if (~rxd) begin
                    status <= s_start_bit;
                    rdata <= 8'b0;
                end
            end else if (status == s_wait_half && next) begin
				rdata <= rxbuf;
				rdata_ready <= 1'b1;
				status <= s_idle;
			end else if (status == s_stop_bit && next) begin
				if (~rxd) begin
				    ferr <= 1'b1;
				end
				status <= status + 1'b1;
			end else if (next) begin
				status <= status + 1'b1;
				rxbuf[7] <= rxd;
				rxbuf[6:0] <= rxbuf[7:1]; 
			end         
        end
    end
   
endmodule
`default_nettype wire