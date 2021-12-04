`default_nettype none
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/11 17:19:39
// Design Name: 
// Module Name: ram_block
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

module ram_block_data(
    input wire clk,
    input wire we,
    input wire [9:0] addr,
    input wire [31:0] di,
    output reg [31:0] dout 
    );

    (* ram_style = "block" *) reg [31:0] ram [1023:0];

    always @(posedge clk) begin
        if (we) begin
            ram[addr] <= di;
            dout <= di;
        end else begin
            dout <= ram[addr];
        end
    end

endmodule



module ram_block_inst(
    input wire clk,
    input wire we,
    input wire [9:0] raddr,
    input wire [9:0] waddr,
    input wire [31:0] di,
    output reg [31:0] dout 
    );

    (* ram_style = "block" *) reg [31:0] ram [1023:0];

    initial begin
        $readmemb("bootloader.mem",ram);
    end

    logic [31:0] dout1, dout2;
    always @(posedge clk) begin
        if (we) begin
            ram[waddr] <= di;
            dout1 <= di;
        end else begin
            dout1 <= ram[waddr];
        end
        dout2 <= ram[raddr];
    end

    assign dout = ((raddr == waddr && we) ? dout1 : dout2);
endmodule
`default_nettype wire
