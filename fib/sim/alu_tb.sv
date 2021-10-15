`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/11 22:18:24
// Design Name: 
// Module Name: alu_tb
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


module alu_tb();
    logic clk;
    logic [31:0] src0;
    logic [31:0] src1;
    logic [1:0] aluop;// 00 -> +
                      // 01 -> -
                      // 10 -> slt 
    logic zero;
    logic [31:0] result;

    alu alu(.src0(src0),
            .src1(src1),
            .aluop(aluop),
            .zero(zero),
            .result(result));

    parameter CYCLE = 10;
    always #(CYCLE/2) begin
        clk = ~clk;
    end

    initial begin
        clk = 0;

        @(posedge clk);
        src0 = 32'h0101_0101;
        src1 = 32'h1010_1010;
        aluop = 2'b00;
        // result = 32'h1111_1111;

        @(posedge clk);
        src0 = 32'h0101_0102;
        src1 = 32'hffff_fffe;
        aluop = 2'b00;
        // result = 32'h0101_0100;

        @(posedge clk);
        src0 = 32'h0202_0202;
        src1 = 32'h0101_0101;
        aluop = 2'b01;
        // result = 32'h0101_0101;

        @(posedge clk);
        src0 = 32'hffff_fffe;
        src1 = 32'hffff_ffff;
        aluop = 2'b01;
        

        @(posedge clk);
        src0 = 32'h8080_0000;
        src1 = 32'h1010_1010;
        aluop = 2'b10;
        // result = 1'b1;

    end

endmodule
