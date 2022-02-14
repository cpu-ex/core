`default_nettype none
`timescale 1ns / 1ps
`include "def.sv"

module memory
   (input wire clk,
    input wire rstn,
    input wire enable,
    output wire fin,

    output logic [5:0] rd,
    output logic [5:0] rd2,
    output logic [5:0] rd3,
    output logic [5:0] rd4,
    output logic [5:0] rd5,
    output logic regwrite,
    output logic vec_regwrite,
    output logic imemwrite,
    output logic [31:0] imemwaddr,
    output logic [31:0] imemwdata,

    // cache
    output logic [31:0] addr,
    output logic [31:0] wdata, 
    input wire [31:0] rdata,
    output logic write_enable,
    output logic read_enable,
    input wire miss,
    output logic [127:0] vec_wdata,
    input wire [127:0] vec_rdata,
    output logic vec_mode,
    output logic [3:0] vec_mask,

    input Inst inst,
    input wire [31:0] aluresult,
    input wire [31:0] result,
    input wire [31:0] rdata1,
    input wire [127:0] vec_data,
    input wire [7:0] uart_rx_data,
    input wire empty,
    input wire full,

    output Inst inst_out,
    output logic [31:0] regwdata,
    output logic [127:0] vec_memrdata,
    output logic uart_rd_en,
    output logic uart_wr_en,
    output logic [7:0] uart_tx_data
   );

    Inst inst_EM_reg;
    logic [31:0] aluresult_EM_reg;
    logic [31:0] result_EM_reg;
    logic [31:0] rdata1_EM_reg;
    logic [127:0] vec_data_EM_reg;
    always_ff @(posedge clk) begin
        if (~rstn) begin
            inst_EM_reg <= '{default : '0};
            aluresult_EM_reg <= 32'b0;
            result_EM_reg <= 32'b0;
            rdata1_EM_reg <= 32'b0;
            vec_data_EM_reg <= 128'b0;
        end else begin
            if (enable) begin
                inst_EM_reg <= inst;
                aluresult_EM_reg <= aluresult;
                result_EM_reg <= result;
                rdata1_EM_reg <= rdata1;
                vec_data_EM_reg <= vec_data;
            end
        end
    end 

    /* ----- data memory ----- */
    localparam UART_ADDR = 26'h3fffffc;
    logic [31:0] memrdata_;

    assign addr = miss ? aluresult_EM_reg:
                  aluresult;
    assign wdata = miss ? rdata1_EM_reg:
                   rdata1;
    assign write_enable = miss ? 1'b0:
                          (inst.memwrite && (addr[25:0] != UART_ADDR[25:0]));
    assign read_enable = miss ? 1'b0:
                         (inst.memread && (addr[25:0] != UART_ADDR[25:0]));
    assign memrdata_ = rdata;
    
    /* --- vec --- */
    assign vec_wdata = miss ? vec_data_EM_reg:
                       vec_data; 
    assign vec_mode = miss ? inst_EM_reg.vecmode:
                      inst.vecmode;
    assign vec_mask = miss ? inst_EM_reg.vecmask:
                      inst.vecmask;
    assign vec_memrdata = vec_rdata;
    // localparam _vecrdata = 128'haaaaaaaa_aaaaaaaa_aaaaaaaa_aaaaaaaa;
    // assign vec_memrdata = _vecrdata;
                          
    // 1 idle -> lw or sw
    // 1 idle -> idle
    // 2 lw or sw (hit) -> idle
    // 2 lw or sw (hit) -> lw or sw
    // 3 lw or sw (miss) -> idle
    // 3 lw or sw (miss) -> lw or sw
    // don't forget imem swi !(if imem stall , I have to change code)
    /* ----- data memory ----- */

    logic [31:0] memrdata;
    assign memrdata = aluresult_EM_reg[25:0] == UART_ADDR[25:0] ? {24'b0,uart_rx_data}:
                      memrdata_;
    assign uart_rd_en = inst_EM_reg.memread  && aluresult_EM_reg[25:0] == UART_ADDR[25:0];
    assign uart_wr_en = inst_EM_reg.memwrite && aluresult_EM_reg[25:0] == UART_ADDR[25:0];
    assign uart_tx_data = rdata1_EM_reg[7:0];

    mux2 regwdatamux2(.data0(result_EM_reg),
                      .data1(memrdata),
                      .s(inst_EM_reg.memtoreg),
                      .data(regwdata));
    
    assign rd = inst_EM_reg.rd;
    assign rd2 = inst_EM_reg.reg2;
    assign rd3 = inst_EM_reg.reg3;
    assign rd4 = inst_EM_reg.reg4;
    assign rd5 = inst_EM_reg.reg5;
    assign regwrite = inst_EM_reg.regwrite;
    assign vec_regwrite = inst_EM_reg.vec_regwrite;
    assign imemwrite = inst_EM_reg.imemwrite;
    assign imemwaddr = aluresult_EM_reg;
    assign imemwdata = rdata1_EM_reg;
    assign inst_out = inst_EM_reg;
    assign fin = ~(uart_rd_en && empty) && ~(uart_wr_en && full) && ~miss;


endmodule

`default_nettype wire
