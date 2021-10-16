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

    parameter CYCLE = 10;
    always #(CYCLE/2) begin
        clk = ~clk;
    end

    cpu cpu(.clk(clk),
            .rstn(rstn));

    initial begin
        clk = 0;
        rstn = 0;
        $readmemb("data_mem.mem",cpu.dmem.ram);
        $readmemb("inst_mem.mem",cpu.imem.ram);

        @(posedge clk);
        #2
        rstn = 1;

        #((CYCLE)*20)

        $finish();
    end

endmodule
