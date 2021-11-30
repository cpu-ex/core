
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
    input logic [31:0] aluresult,
    input logic [31:0] result,
    input logic [31:0] rdata1,
    input logic [7:0] uart_rx_data,
    input logic empty,
    input logic full,

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