`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/11 22:18:24
// Design Name: 
// Module Name: util_tb
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


module util_tb();
    logic clk;
    logic rstn;
    logic s1;
    logic [1:0] s2;
    logic [31:0] data1, data2, data3;
    logic [31:0] q;

    parameter CYCLE = 10;
    always #(CYCLE/2) begin
        clk = ~clk;
    end

    mux2 mux2(.data0(32'h0000_0001),
              .data1(32'h0000_0002),
              .s(s1),
              .data(data1));

    mux4 mux4(.data0(32'h0000_0003),
              .data1(32'h0000_0004),
              .data2(32'h0000_0005),
              .data3(32'h0000_0006),
              .s(s2),
              .data(data2));

    flop flop(.clk(clk),
              .rstn(rstn),
              .data(data3),
              .q(q));

    initial begin
        clk = 0;
        rstn = 0;
        s1 = 0;
        s2 = 0;
        data3 = 0;

        @(posedge clk);
        #2
        rstn = 1;

        @(posedge clk);
        #2
        s1 = 1'b0;
        s2 = 2'b00;

        @(posedge clk);
        #2
        s1 = 1'b1;
        s2 = 2'b01;

        @(posedge clk);
        #2
        s2 = 2'b10;

        @(posedge clk);
        #2 
        s2 = 2'b11;

        @(posedge clk);
        #2
        data3 = 32'h0101_0101;

        @(posedge clk);
        #2
        data3 = 32'h1010_1010;
        rstn = 0;

        @(posedge clk);
        #2

        $finish();
    end

endmodule
