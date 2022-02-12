`default_nettype none
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
      output logic [WIDTH-1:0] data);

    always_comb begin
        (* parallel_case *) unique case(s)
            2'b00: data = data0;
            2'b01: data = data1;
            2'b10: data = data2;
            2'b11: data = data3;
        endcase
    end
endmodule

`default_nettype wire
