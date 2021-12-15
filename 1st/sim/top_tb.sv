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
    assign program_size = {30'd27,2'b00};

    int i, j;
    integer mcd;
    logic [63:0] step_count;
    wire [101:0] flushed_inst0 = 102'b0; 
    wire [101:0] flushed_inst1 = 102'b1101000010; 
    logic first; // instr at 0 execute twice ?
    logic write_enable_before; 

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

    // output for debug
    always @(posedge clk) begin
        if (~first && 
            rstn   && 
            (top_wrap.top.cpu.inst_MW_reg != flushed_inst0) && 
            (top_wrap.top.cpu.inst_MW_reg != flushed_inst1) && 
            (write_enable_before)) begin

            // step
            $fwrite(mcd, "step:%h", step_count);

            // pc
            $fwrite(mcd, " pc:%h", top_wrap.top.cpu.inst_MW_reg.pc);

            // register file 
            for (j=0;j<32;j++) begin
                $fwrite(mcd, " x%0d:%h",j, top_wrap.top.cpu.regfile.reg_file[j]);
            end
            for (j=32;j<64;j++) begin 
                $fwrite(mcd, " f%0d:%h",j-32, top_wrap.top.cpu.regfile.reg_file[j]);       
            end
            $fwrite(mcd,"\n");

            step_count = step_count + 63'b1;
        end else if (rstn && 
                     (top_wrap.top.cpu.inst_MW_reg != flushed_inst0) && 
                     (top_wrap.top.cpu.inst_MW_reg != flushed_inst1) && 
                     (write_enable_before)) begin
            first = 0;
        end
        write_enable_before = top_wrap.top.cpu.write_enable;
    end
    
    initial begin
        mcd = $fopen("vivado_output.txt","w");
    end
    
    final begin
        $fclose(mcd);
    end
    
    initial begin
        clk = 0;
        clk_uart = 0;
        rstn = 0;
        rxd = 1;
        step_count = 0;
        first = 1;

        //$readmemb("data_mem.mem",top_wrap.top.cpu.memory.dmem.ram);
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

        #(600 * 1000);
        $finish;
    end
    

endmodule
