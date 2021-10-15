`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/11 15:00:42
// Design Name: 
// Module Name: 
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


module mux2
    #(parameter WIDTH = 32)
     (input wire [WIDTH-1:0] data0, data1,
      input wire s,
      output wire [WIDTH-1:0] data);

    assign data = s ? data1 : data0;
endmodule

module mux4
    #(parameter WIDTH = 32)
     (input wire [WIDTH-1:0] data0, data1, data2, data3,
      input wire [1:0] s,
      output wire [WIDTH-1:0] data);

    assign data = s == 2'b00 ? data0 :
                  s == 2'b01 ? data1 :
                  s == 2'b10 ? data2 :
                  data3; // s == 2'b11
endmodule

module flop
    #(parameter WIDTH = 32) 
    (input wire clk,
     input wire rstn,
     input wire [WIDTH-1:0] data,
     output reg [WIDTH-1:0] q);

    always_ff @(posedge clk) begin
        if (~rstn) q <= 0;
        else       q <= data;
    end
    
endmodule
