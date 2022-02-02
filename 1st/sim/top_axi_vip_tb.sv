`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/26 14:05:11
// Design Name: 
// Module Name: top_axi_vip_tb
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

`timescale 1ns/1ps

import axi_vip_pkg::*;
import design_2_axi_vip_0_0_pkg::*;

module top_axi_vip_tb();
    localparam TMBIT = 1736;
    localparam TMINTVL = TMBIT*5;
    localparam HALF_TMCLK = 5;
    localparam CLK_PER_HALF_BIT = 86;

    logic [7:0] uart_input [2000:0];
    logic [31:0] uart_input_size;
    assign uart_input_size = {32'd1300};

    int i;
    logic clk;
    logic rstn;
    logic rxd;
    logic txd;

    design_2_wrapper u1(.UART_RXD_OUT(rxd),
                        .UART_TXD_IN(txd),
                        .sys_clock(clk),
                        .reset(rstn));
    
    task uart(input logic [7:0] data);
        begin
        #TMBIT txd = 0;
        #TMBIT txd = data[0];
        #TMBIT txd = data[1];
        #TMBIT txd = data[2];
        #TMBIT txd = data[3];
        #TMBIT txd = data[4];
        #TMBIT txd = data[5];
        #TMBIT txd = data[6];
        #TMBIT txd = data[7];
        #TMBIT txd = 1;
        end
    endtask
    
    always #(HALF_TMCLK) begin
        clk = ~clk;
    end

    initial begin
        clk = 0;
        rstn = 0;
        txd = 1;

        $readmemb("data_mem.mem",uart_input);
        #(HALF_TMCLK*100);
        // wait fifo's reset
        @(posedge clk);
        #2
        rstn = 1;

        for (i=0;i<uart_input_size;i++) begin
            uart(uart_input[i]);
        end

        #(600 * 1000);
        $finish;
    end

    // VIP Slave agent 
    design_2_axi_vip_0_0_slv_mem_t agent;

    initial begin
        agent = new("AXI Slave Agent",u1.design_2_i.axi_vip_0.inst.IF);
        agent.start_slave();
    end
    
endmodule;
