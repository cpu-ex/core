`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/11 22:18:24
// Design Name: 
// Module Name: cpu_tb
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


module cpu_tb();
    logic clk;
    logic rstn;
    logic [31:0] pc_;
    logic [31:0] data;

    parameter CYCLE = 10;
    always #(CYCLE/2) begin
        clk = ~clk;
    end

    cpu_wrap cpu(.clk(clk),
                 .rstn(rstn),
                 .pc_(pc_),
                 .data(data));

    initial begin
        clk = 0;
        rstn = 0;
        // $readmemb("data_mem.mem",cpu.cpu.dmem.ram);
        // $readmemb("inst_mem.mem",cpu.cpu.imem.ram);

        @(posedge clk);
        #2
        rstn = 1;

        #((CYCLE)*20)

        $finish();
    end

endmodule
