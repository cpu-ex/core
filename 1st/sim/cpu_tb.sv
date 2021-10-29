`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/25 17:33:12
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
    logic clk, rstn, empty, rd_en, full, wr_en;
    logic [7:0] rdata, tdata;

    parameter CYCLE = 10;
    always #(CYCLE/2) begin
        clk = ~clk;
    end

    cpu cpu(.clk(clk),
            .rstn(rstn),
            .uart_rx_data(rdata),
            .empty(empty),
            .uart_rd_en(rd_en),
            .uart_tx_data(tdata),
            .full(full),
            .uart_wr_en(wr_en));
    
    initial begin
        clk = 0;
        rstn = 0;
        empty = 1;
        full = 0;
        rdata = 8'b0;

        $readmemb("inst_mem.mem",cpu.imem.ram);
        $readmemb("data_mem.mem",cpu.dmem.ram);

        @(posedge clk);
        #2
        rstn = 1;

        # (CYCLE*200);
        $finish;
    end


endmodule
