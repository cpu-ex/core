`default_nettype none
`timescale 1ns / 1ps

// temporary memory 
// always cache miss
// stall 0 ~ 16 clock virtually
module memory_interface_wrap
   (input wire clk,
    input wire rstn,
    input wire [31:0] addr,
    input wire [31:0] data_in,
    input wire write_enable,
    input wire read_enable,
    output wire [31:0] data_out,
    output wire miss
   );

   memory_interface dmem(.clk(clk),
                         .rstn(rstn),
                         .addr(addr),
                         .data_in(data_in),
                         .write_enable(write_enable),
                         .read_enable(read_enable),
                         .data_out(data_out),
                         .miss(miss));

endmodule
`default_nettype wire
