`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/01 20:08:51
// Design Name: 
// Module Name: top_tb
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


// HALF_TMCLK_UART corresponds to 100 MHz system clock
// HALF_TMCLK_UART = 10^9 / (100M) / 2

// HALF_TMCLK corresponds to 10 MHz system clock
// HALF_TMCLK = 10^9 / (10M) / 2

// TMBIT and CLK_PER_HALF_BIT corresponds to 576000 bps
// TMBIT = 10^9 / baud rate
// CLK_PER_HALF_BIT = 100M / baud rate / 2

module top_tb();
    localparam TMBIT = 1736;
    localparam TMINTVL = TMBIT*5;
    localparam HALF_TMCLK_UART = 5;
    localparam HALF_TMCLK = 50;
    localparam CLK_PER_HALF_BIT = 86;

    logic clk, clk_uart, rstn, rxd, txd;
    logic [7:0] prog [2000:0];
    logic [31:0] program_size;
    assign program_size = {30'd7,2'b00};

    int i;

    top_wrap #(CLK_PER_HALF_BIT) top_wrap(.clk(clk),
                                          .rstn(rstn),
                                          .clk_uart(clk_uart),
                                          .rxd(rxd),
                                          .txd(txd));

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

    always #(HALF_TMCLK_UART) begin
        clk_uart = ~clk_uart;
    end
    
    initial begin
        clk = 0;
        clk_uart = 0;
        rstn = 0;
        rxd = 1;

        $readmemb("data_mem.mem",top_wrap.top.cpu.dmem.ram);
        $readmemb("inst_mem.mem",prog);

        #(HALF_TMCLK*100);
        // wait fifo's reset
        @(posedge clk);
        #2
        rstn = 1;

        uart(program_size[31:24]);
        uart(program_size[23:16]);
        uart(program_size[15:8]);
        uart(program_size[7:0]);
        for (i=0;i<program_size;i++) begin
            uart(prog[i]);
        end

        #(HALF_TMCLK*200);
        $finish;
    end

endmodule
