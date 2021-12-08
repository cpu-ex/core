`default_nettype none
`timescale 1ns / 1ps
`include "def.sv"

module memory
   (/* verilator lint_off UNUSED */ input wire clk,
    /* verilator lint_off UNUSED */ input wire rstn,
    /* verilator lint_off UNUSED */ input wire enable,
    output wire fin,

    output logic [5:0] rd,
    output logic regwrite,
    output logic imemwrite,
    output logic [31:0] imemwaddr,
    output logic [31:0] imemwdata,

    input Inst inst,
    input wire [31:0] aluresult,
    input wire [31:0] result,
    input wire [31:0] rdata1,
    input wire [7:0] uart_rx_data,
    input wire empty,
    input wire full,

    output Inst inst_out,
    output logic [31:0] regwdata,
    output logic uart_rd_en,
    output logic uart_wr_en,
    output logic [7:0] uart_tx_data
   );

    Inst inst_EM_reg;
    logic [31:0] aluresult_EM_reg;
    logic [31:0] result_EM_reg;
    logic [31:0] rdata1_EM_reg;
    always @(posedge clk) begin
        if (~rstn) begin
            inst_EM_reg <= '{default : '0};
            aluresult_EM_reg <= 32'b0;
            result_EM_reg <= 32'b0;
            rdata1_EM_reg <= 32'b0;
        end else begin
            if (enable) begin
                inst_EM_reg <= inst;
                aluresult_EM_reg <= aluresult;
                result_EM_reg <= result;
                rdata1_EM_reg <= rdata1;
            end
        end
    end 

    /* ----- data memory ----- */
    // WIP
    // memory_interface(.clk(clk),                    // wire
    //                  .rstn(rstn),                  // wire
    //                  .addr(addr),                  // wire [31:0] 
    //                  .data_in(data_in),            // wire [31:0] write data 
    //                  .write_enable(write_enable),  // wire
    //                  .read_enable(read_enable),    // wire
    //                  .data_out(data_out),          // wire [31:0] read data 
    //                  .ready(ready),                // wire        ready == 1'b1 <-> core can assert write_enable or read_enable
    //                  .valid(valid));               // wire        valid == 1'b1 <-> memory finish load or store
    // localparam s_idle = 1'd0;
    // localparam s_wait = 1'd1;
    // logic state;
    // logic [31:0] addr;
    // logic [31:0] wdata;
    // logic [31:0] rdata;
    // logic write_enable;
    // logic read_enable;
    // logic ready;
    // logic valid;
    // always_ff @(posedge clk) begin
    //     if (~rstn) begin
    //         state <= s_idle;
    //     end else begin
    //         if (state == s_idle) begin

    //         end else if (state == s_wait) begin

    //         end
    //     end
    // end
    /* ----- data memory ----- */

    logic [31:0] memrdata_;
    ram_block_data dmem(.clk(clk),
                        .we(inst.memwrite),
                        .addr(aluresult[11:2]),
                        .di(rdata1),
                        .dout(memrdata_));

    logic [31:0] memrdata;
    assign memrdata = aluresult_EM_reg[9:0] == 10'b0000000000 ? {24'b0,uart_rx_data}:
                      aluresult_EM_reg[9:0] == 10'b0000000100 ? {31'b0,~empty}:
                      aluresult_EM_reg[9:0] == 10'b0000001000 ? {31'b0,~full}:
                      memrdata_;
    assign uart_rd_en = inst_EM_reg.memread && aluresult_EM_reg[9:0] == 10'b0000000000;
    assign uart_wr_en = inst_EM_reg.memwrite && aluresult_EM_reg[9:0] == 10'b0000001100;
    assign uart_tx_data = rdata1_EM_reg[7:0];

    mux2 regwdatamux2(.data0(result_EM_reg),
                      .data1(memrdata),
                      .s(inst_EM_reg.memtoreg),
                      .data(regwdata));
    
    assign rd = inst_EM_reg.rd;
    assign regwrite = inst_EM_reg.regwrite;
    assign imemwrite = inst_EM_reg.imemwrite;
    assign imemwaddr = aluresult_EM_reg;
    assign imemwdata = rdata1_EM_reg;
    assign inst_out = inst_EM_reg;
    assign fin = 1'b1;


endmodule
`default_nettype wire
