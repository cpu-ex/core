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
    input wire [15:0] addr,
    input wire [31:0] di,
    output reg [31:0] dout 
    );

    (* ram_style = "block" *) reg [31:0] ram [((2 ** 16) - 1):0];

    always_ff @(posedge clk) begin
        if (we) begin
            ram[addr] <= di;
        end else begin
            dout <= ram[addr];
        end
    end

endmodule



module ram_block_inst(
    input wire clk,
    input wire we,
    input wire [14:0] raddr,
    input wire [14:0] waddr,
    input wire [31:0] di,
    output reg [31:0] dout 
    );

    (* ram_style = "block" *) reg [31:0] ram [((2  ** 15) - 1):0];

    initial begin
        $readmemb("bootloader.mem",ram);
    end

    always_ff @(posedge clk) begin
        if (we) begin
            ram[waddr] <= di;
        end
        dout <= ram[raddr];
    end

    // assume raddr != waddr
    // only bootloader have swi instruction  
endmodule
`default_nettype wire
