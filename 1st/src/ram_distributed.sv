`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/15 13:04:26
// Design Name: 
// Module Name: ram_distributed
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

// wordorbyte
// 1'b0 -> word
// 1'b1 -> byte

module ram_distributed(
    input clk,
    input we,
    input [9:0] raddr,
    input [9:0] waddr,
    input wordorbyte,
    input [31:0] di,
    output[31:0] dout 
    );

    //(* ram_style = "distributed" *) reg [7:0] ram [1023:0];
    (* ram_style = "distributed" *) reg [7:0] ram [1030:0];

    always @(posedge clk) begin
        if (we) begin
            if (wordorbyte) begin
                ram[waddr] <= di[7:0];
            end else begin
                {ram[waddr], ram[waddr+1], ram[waddr+2], ram[waddr+3]} <= di; // big endian
            end
        end
    end

    assign dout = {ram[raddr], ram[raddr+1], ram[raddr+2], ram[raddr+3]};
endmodule