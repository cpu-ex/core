`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/19 15:48:43
// Design Name: 
// Module Name: cpu_wrap
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


module cpu_wrap(
    input wire clk,
    input wire rstn,
    output wire [31:0] pc_,
    output wire [31:0] data
    );
    
    cpu cpu(.clk(clk),
            .rstn(rstn),
            .pc_(pc_),
            .output_data(data));

endmodule
