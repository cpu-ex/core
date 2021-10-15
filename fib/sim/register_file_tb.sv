`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/10 15:50:06
// Design Name: 
// Module Name: register_file_tb
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


module register_file_tb();
    reg clk;
    reg rstn;
    reg [4:0] raddr0, raddr1, waddr;
    reg we;
    reg [31:0] wdata, rdata0, rdata1;
    register_file register_file1(.clk(clk), 
                                 .rstn(rstn),
                                 .raddr0(raddr0),
                                 .raddr1(raddr1),
                                 .we(we),
                                 .waddr(waddr),
                                 .wdata(wdata),
                                 .rdata0(rdata0),
                                 .rdata1(rdata1));
    
    parameter CYCLE = 10;
    always #(CYCLE/2) begin
        clk = ~clk;
    end
    
    initial begin
        clk = 0;
        rstn = 0;
        raddr0 = 0;
        raddr1 = 0;
        waddr = 0;
        we = 0;
        wdata = 0;
        rdata0 = 0;
        rdata1 = 0;

        @(posedge clk);
        #2
        rstn = 1;
        
        @(posedge clk);
        #2
        we = 1;
        raddr0 = 1; // -> rdata0 = 0
        raddr1 = 2; // -> rdata1 = 0
        waddr = 2;
        wdata = 32'h0123_4567;

        @(posedge clk);
        #2
        raddr0 = 2; // -> rdata0 = 32'h0123_4567;
        raddr1 = 1; // -> rdata1 = 0
        waddr = 1;
        wdata = 32'h89AB_CDEF;

        @(posedge clk);
        #2
        raddr0 = 2; // -> rdata0 = 32'h0123_4567;
        raddr1 = 1; // -> rdata1 = 32'h89AB_CDEF;
        waddr = 2;
        wdata = 32'h1234_5678;

        @(posedge clk);
        #2
        raddr0 = 2; // -> rdata0 = 32'h1234_5678;
        raddr1 = 0; // -> rdata1 = 0;
        waddr = 0;
        wdata = 32'h1234_5678;

        @(posedge clk);
        #2
        we = 0;
        raddr0 = 0; // -> rdata0 = 0;
        raddr1 = 1; // -> rdata1 = 32'h89AB_CDEF;
        waddr = 3;
        wdata = 32'h1234_5678;

        @(posedge clk);
        #2
        raddr0 = 0; // -> rdata0 = 0;
        raddr1 = 3; // -> rdata1 = 0;
        

        $finish();
    end

endmodule
