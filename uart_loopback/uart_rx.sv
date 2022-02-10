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
// 2304000 baud rate
// 100Mhz -> clk_per_half_bit = 21
module uart_rx #(CLK_PER_HALF_BIT = 21) (
               output logic [7:0] rdata,
               output logic       rdata_ready,
               output logic       ferr,
               input wire         rxd,
               input wire         clk,
               input wire         rstn);

    localparam e_clk_halfbit = CLK_PER_HALF_BIT - 1;
    localparam e_clk_bit = CLK_PER_HALF_BIT * 2 - 1;

    logic [7:0]                  rxbuf;
    logic [3:0]                  status;
    logic [31:0]                 counter;
    (*ASYNC_REG = "true"*) reg [2:0] sync_reg;
   
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
            rxbuf <= 8'b0;
            rdata <= 8'b0;
            rdata_ready <= 1'b0;
            ferr <= 1'b0;
            sync_reg <= 3'b111;
        end else begin
            sync_reg[0] <= rxd;
            sync_reg[2:1] <= sync_reg[1:0];
            if (status == s_idle) begin
                if (~sync_reg[2]) begin
                    status <= s_start_bit;
                    counter <= 32'b0;
                end 
                rdata_ready <= 1'b0;
            end else if (status == s_start_bit) begin
                if (counter == e_clk_halfbit) begin
                    status <= s_bit_0;
                    counter <= 32'b0;
                end else begin
                    counter <= counter + 32'b1;
                end
            end else if (status == s_stop_bit) begin
                if (counter == e_clk_bit) begin
                    status <= s_idle;
                    counter <= 32'b0;
                    rdata <= rxbuf;
                    rdata_ready <= 1'b1;
                    ferr <= ~sync_reg[2];
                end else begin
                    counter <= counter + 32'b1;
                end
            end else begin
                if (counter == e_clk_bit) begin
                    status <= status + 4'b1;
                    counter <= 32'b0;
                    rxbuf[7] <= sync_reg[2];
                    rxbuf[6:0] <= rxbuf[7:1];
                end else begin
                    counter <= counter + 32'b1;
                end
            end
        end
    end

   
endmodule
`default_nettype wire