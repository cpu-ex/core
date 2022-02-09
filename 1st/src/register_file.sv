`default_nettype none
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/10 15:27:07
// Design Name: 
// Module Name: register_file
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

// 0-31 integer register 
// 32-63 floating point register
module register_file(
    input wire clk,
    input wire rstn,
    input wire [5:0] raddr0,
    input wire [5:0] raddr1,
    input wire [5:0] raddr2,
    input wire [5:0] raddr3,
    input wire [5:0] raddr4,
    input wire [5:0] raddr5,
    input wire we,
    input wire vecwe,
    input wire [5:0] waddr,
    input wire [5:0] waddr2,
    input wire [5:0] waddr3,
    input wire [5:0] waddr4,
    input wire [5:0] waddr5,
    input wire [31:0] wdata,
    input wire [31:0] wdata2,
    input wire [31:0] wdata3,
    input wire [31:0] wdata4,
    input wire [31:0] wdata5,

    output wire [31:0] rdata0,
    output wire [31:0] rdata1,
    output wire [31:0] rdata2,
    output wire [31:0] rdata3,
    output wire [31:0] rdata4,
    output wire [31:0] rdata5
    );

    reg [31:0] reg_file[63:0];

    always_ff @(posedge clk) begin
        if (~rstn) begin
            for (int i = 0;i < 64; i++) begin
                reg_file[i] <= 0;
            end
        end else begin
            if (we && waddr != 0) begin
                reg_file[waddr] <= wdata;
            end 
            if (vecwe) begin
                // expect mask[i] == 0 -> waddr_i == x0
                reg_file[waddr2] <= waddr2 == 0 ? 32'b0 : wdata2;
                reg_file[waddr3] <= waddr3 == 0 ? 32'b0 : wdata3;
                reg_file[waddr4] <= waddr4 == 0 ? 32'b0 : wdata4;
                reg_file[waddr5] <= waddr5 == 0 ? 32'b0 : wdata5;
            end
        end
    end

    assign rdata0 = (raddr0 == waddr && we && waddr != 0) ? wdata : reg_file[raddr0];
    assign rdata1 = (raddr1 == waddr && we && waddr != 0) ? wdata : reg_file[raddr1];
    assign rdata2 = (raddr2 == waddr && we && waddr != 0) ? wdata : reg_file[raddr2];
    assign rdata3 = (raddr3 == waddr && we && waddr != 0) ? wdata : reg_file[raddr3];
    assign rdata4 = (raddr4 == waddr && we && waddr != 0) ? wdata : reg_file[raddr4];
    assign rdata5 = (raddr5 == waddr && we && waddr != 0) ? wdata : reg_file[raddr5];

endmodule

`default_nettype wire
