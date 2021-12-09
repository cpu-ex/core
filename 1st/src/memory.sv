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
    localparam UART_ADDR = 10'b0000000000;

    logic [31:0] addr;
    logic [31:0] wdata; // data_in
    logic [31:0] rdata; // data_out
    logic write_enable;
    logic read_enable;
    logic ready;
    logic miss;
    logic [31:0] memrdata_;

    assign addr = miss ? aluresult_EM_reg:
                  aluresult;
    assign wdata = miss ? rdata1_EM_reg:
                   rdata1;
    assign write_enable = miss ? 1'b0:
                          (inst.memwrite && (addr[9:0] != UART_ADDR));
    assign read_enable = miss ? 1'b0:
                         (inst.memread && (addr[9:0] != UART_ADDR));
    assign memrdata_ = rdata;

    memory_interface dmem(.clk(clk),                   // input wire
                          .rstn(rstn),                 // input wire 
                          .addr(addr),                 // input wire [31:0]
                          .data_in(wdata),             // input wire [31:0] write data  
                          .write_enable(write_enable), // input wire
                          .read_enable(read_enable),   // input wire
                          .data_out(rdata),            // output wire [31:0] read data
                          .ready(ready),               // output wire        ready == 1'b1 <-> core can assert write_enable or read_enable 
                          .miss(miss));                // output wire        miss == 1'b0 <-> memory finish load or store
                                                       //                    miss == 1'b1 <-> core must wait memory
                          
    // 1 idle -> lw or sw
    // 1 idle -> idle
    // 2 lw or sw (hit) -> idle
    // 2 lw or sw (hit) -> lw or sw
    // 3 lw or sw (miss) -> idle
    // 3 lw or sw (miss) -> lw or sw
    // don't forget imem swi !(if imem stall , I have to change code)
    /* ----- data memory ----- */

    logic [31:0] memrdata;
    assign memrdata = aluresult_EM_reg[9:0] == UART_ADDR ? {24'b0,uart_rx_data}:
                      memrdata_;
    assign uart_rd_en = inst_EM_reg.memread  && aluresult_EM_reg[9:0] == UART_ADDR;
    assign uart_wr_en = inst_EM_reg.memwrite && aluresult_EM_reg[9:0] == UART_ADDR;
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
    assign fin = ~(uart_rd_en && empty) && ~(uart_wr_en && full) && ~miss;


endmodule

// temporary memory 
// always cache miss
// stall 0 ~ 16 clock virtually
module memory_interface
   (input wire clk,
    input wire rstn,
    input wire [31:0] addr,
    input wire [31:0] data_in,
    input wire write_enable,
    input wire read_enable,
    output logic [31:0] data_out,
    output logic ready,
    output logic miss
   );

    logic [31:0] temp_data;
    ram_block_data dmem(.clk(clk),
                        .we(write_enable),
                        .addr(addr[11:2]),
                        .di(data_in),
                        .dout(temp_data));

    logic [3:0] cnt;
    logic before_read_enable;
    always_ff @(posedge clk) begin
        if (~rstn) begin
            cnt <= 4'b0;
            ready <= 1'b1;
            miss <= 1'b0;
            before_read_enable <= 1'b0;
        end else begin
            if (read_enable) begin
                ready <= 1'b0;
                miss <= 1'b1;
                before_read_enable <= 1'b1;
            end else if (before_read_enable) begin
                data_out <= temp_data;
                before_read_enable <= 1'b0;
            end else if (cnt == 4'b00) begin
                ready <= 1'b1;
                miss <= 1'b0;
            end
            cnt <= cnt + 4'b1;
        end
    end

endmodule

`default_nettype wire
