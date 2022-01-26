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
        #TMBIT rxd = 0;
        #TMBIT rxd = data[0];
        #TMBIT rxd = data[1];
        #TMBIT rxd = data[2];
        #TMBIT rxd = data[3];
        #TMBIT rxd = data[4];
        #TMBIT rxd = data[5];
        #TMBIT rxd = data[6];
        #TMBIT rxd = data[7];
        #TMBIT rxd = 1;
        end
    endtask
    
    always #(HALF_TMCLK) begin
        clk = ~clk;
    end

    initial begin
        clk = 0;
        rstn = 0;
        rxd = 1;

        #(HALF_TMCLK*100);
        // wait fifo's reset
        @(posedge clk);
        #2
        rstn = 1;

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
