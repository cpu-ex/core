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


module register_file(
    input wire clk,
    input wire rstn,
    input wire [4:0] raddr0,
    input wire [4:0] raddr1,
    input wire we,
    input wire [4:0] waddr,
    input wire [31:0] wdata,

    output wire [31:0] rdata0,
    output wire [31:0] rdata1
    );

    reg [31:0] reg_file[31:0];

    always_ff @(posedge clk) begin
        if (~rstn) begin
            for (int i = 0;i < 32; i++) begin
                reg_file[i] <= 0;
            end
        end else if (we && waddr != 0) begin
            reg_file[waddr] <= wdata;
        end
    end

    assign rdata0 = reg_file[raddr0];
    assign rdata1 = reg_file[raddr1];

endmodule


module fregister_file(
    input wire clk,
    input wire rstn,
    input wire [4:0] raddr0,
    input wire [4:0] raddr1,
    input wire we,
    input wire [4:0] waddr,
    input wire [31:0] wdata,

    output wire [31:0] rdata0,
    output wire [31:0] rdata1
    );

    reg [31:0] reg_file[31:0];

    always_ff @(posedge clk) begin
        if (~rstn) begin
            for (int i = 0;i < 32; i++) begin
                reg_file[i] <= 0;
            end
        end else if (we) begin
            reg_file[waddr] <= wdata;
        end
    end

    assign rdata0 = reg_file[raddr0];
    assign rdata1 = reg_file[raddr1];

endmodule