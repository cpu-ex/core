//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/24 23:46:17
// Design Name: 
// Module Name: cpu
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
`default_nettype none
`timescale 1ns / 1ps
`include "def.sv"

module cpu(
    input wire clk,
    input wire rstn,
    // uart_rx_unit
    input wire [7:0] uart_rx_data,
    input wire empty,
    output wire uart_rd_en,
    // uart_tx_unit
    output wire [7:0] uart_tx_data,
    input wire full,
    output wire uart_wr_en,
    // cache
    output logic [31:0] addr_cache,
    output logic [31:0] wdata_cache, 
    input wire [31:0] rdata_cache, 
    output logic write_enable_cache,
    output logic read_enable_cache,
    input wire miss_cache
    );   

    logic [31:0] pc; // fetch stage stall -> pc <= pc
    logic [31:0] pcnext;
    logic [1:0] forward0;
    logic [1:0] forward1;
    logic lwstall;
    logic branchjump_miss;

    wire fetch_rstn;
    wire fetch_enable;
    wire fetch_fin;

    wire decode_rstn;
    wire decode_enable;
    wire decode_fin;

    wire exec_rstn;
    wire exec_enable;
    wire exec_fin;

    wire memory_rstn;
    wire memory_enable;
    wire memory_fin;

    wire write_rstn;
    wire write_enable;
    wire write_fin;

    logic i_jal;
    logic [31:0] pc_jal;
    logic [31:0] imemraddr;
    logic [31:0] imemrdata;
    logic [31:0] pc_FD;
    logic [31:0] instr_FD;

    fetch fetch(.clk(clk),
                .rstn(rstn && fetch_rstn),
                .enable(fetch_enable),
                .fin(fetch_fin),
                .imemraddr(imemraddr),
                .imemrdata(imemrdata),
                .branchjump_miss(branchjump_miss),
                .i_jal(i_jal),
                .pc_jal(pc_jal),
                .pc(pc),
                .pcnext(pcnext),
                .pc_out(pc_FD),
                .instr(instr_FD));

    // FD
    logic [31:0] pc_FD_reg;
    logic [31:0] instr_FD_reg;
    always_ff @(posedge clk) begin
        if (~(rstn && decode_rstn)) begin
            pc_FD_reg <= 32'b0;
            instr_FD_reg <= 32'b0;
        end else begin
            if (decode_enable) begin
                pc_FD_reg <= pc_FD;
                instr_FD_reg <= instr_FD;
            end
        end
    end

   
    logic [5:0] rs0;
    logic [5:0] rs1;
    logic [31:0] rs0data;
    logic [31:0] rs1data;
    logic [31:0] regwdataE;
    logic [31:0] regwdataM;
    Inst inst_DE;
    logic [31:0] src0_DE;
    logic [31:0] src1_DE;
    logic [31:0] rdata0_DE;
    logic [31:0] rdata1_DE;

    decode decode(.clk(clk),
                   .rstn(rstn && decode_rstn),
                   .enable(decode_enable),
                   .fin(decode_fin),
                   .rs0(rs0),
                   .rs1(rs1),
                   .rs0data(rs0data),
                   .rs1data(rs1data),
                   .regwdataE(regwdataE),
                   .regwdataM(regwdataM),
                   .forward0(forward0),
                   .forward1(forward1),
                   .pc(pc_FD_reg),
                   .instr(instr_FD_reg),
                   .inst(inst_DE),
                   .src0(src0_DE),
                   .src1(src1_DE),
                   .rdata0(rdata0_DE),
                   .rdata1(rdata1_DE));

    // DE
    Inst inst_DE_reg;
    logic [31:0] src0_DE_reg;
    logic [31:0] src1_DE_reg;
    logic [31:0] rdata0_DE_reg;
    logic [31:0] rdata1_DE_reg;
    always_ff @(posedge clk) begin
        if (~(rstn && exec_rstn)) begin
            inst_DE_reg <= '{default : '0, fpuop: 4'b1101};
            src0_DE_reg <= 32'b0;
            src1_DE_reg <= 32'b0;
            rdata0_DE_reg <= 32'b0;
            rdata1_DE_reg <= 32'b0;
        end else begin
            if (exec_enable) begin
                inst_DE_reg <= inst_DE;
                src0_DE_reg <= src0_DE;
                src1_DE_reg <= src1_DE;
                rdata0_DE_reg <= rdata0_DE;
                rdata1_DE_reg <= rdata1_DE;
            end
        end
    end 


    logic [5:0] rdE;
    logic regwriteE;
    logic memreadE;
    Inst inst_EM;
    logic [31:0] aluresult_EM;
    logic [31:0] result_EM;
    logic [31:0] rdata1_EM;
    assign regwdataE = result_EM;

    exec exec (.clk(clk),
               .rstn(rstn && exec_rstn),
               .enable(exec_enable),
               .fin(exec_fin),
               .rd(rdE),
               .regwrite(regwriteE),
               .memread(memreadE),
               .branchjump_miss(branchjump_miss),
               .src0(src0_DE_reg),
               .src1(src1_DE_reg),
               .rdata0(rdata0_DE_reg),
               .rdata1(rdata1_DE_reg),
               .inst(inst_DE_reg),
               .pcnext(pcnext),
               .inst_out(inst_EM),
               .aluresult(aluresult_EM),
               .result(result_EM),
               .rdata1_out(rdata1_EM));


    logic [5:0] rdM;
    logic regwriteM;
    logic imemwrite;
    logic [31:0] imemwaddr;
    logic [31:0] imemwdata;

    Inst inst_MW;
    logic [31:0] regwdata_MW;
    assign regwdataM = regwdata_MW;

    memory memory(.clk(clk),
                  .rstn(rstn && memory_rstn),
                  .enable(memory_enable),
                  .fin(memory_fin),
                  .rd(rdM),
                  .regwrite(regwriteM),
                  .imemwrite(imemwrite),
                  .imemwaddr(imemwaddr),
                  .imemwdata(imemwdata),
                  .addr(addr_cache),
                  .wdata(wdata_cache),
                  .rdata(rdata_cache),
                  .write_enable(write_enable_cache),
                  .read_enable(read_enable_cache),
                  .miss(miss_cache),
                  .inst(inst_EM),
                  .aluresult(aluresult_EM),
                  .result(result_EM),
                  .rdata1(rdata1_EM),
                  .uart_rx_data(uart_rx_data),
                  .empty(empty),
                  .full(full),
                  .inst_out(inst_MW),
                  .regwdata(regwdata_MW),
                  .uart_rd_en(uart_rd_en),
                  .uart_wr_en(uart_wr_en),
                  .uart_tx_data(uart_tx_data));

    // MW
    Inst inst_MW_reg;
    logic [31:0] regwdata_MW_reg;
    always_ff @(posedge clk) begin
        if (~(rstn && write_rstn)) begin
            inst_MW_reg <= '{default : '0, fpuop : 4'b1101};
            regwdata_MW_reg <= 32'b0;
        end else begin
            if (write_enable) begin
                inst_MW_reg <= inst_MW;
                regwdata_MW_reg <= regwdata_MW;
            end
        end
    end 
 
    logic [31:0] regwdata;
    logic regwrite;
    logic [5:0] rd;

    write write(.clk(clk),
                .rstn(rstn && write_rstn),
                .enable(write_enable),
                .fin(write_fin),
                .regwdata(regwdata),
                .regwrite(regwrite),
                .rd(rd),
                .inst(inst_MW_reg),
                .regwdata_in(regwdata_MW_reg));
                
    // inst memory
    ram_block_inst imem(.clk(clk), 
                        .we(imemwrite), 
                        .raddr(imemraddr[16:2]),
                        .waddr(imemwaddr[16:2]),  
                        .di(imemwdata),
                        .dout(imemrdata));   

    // reg file
    register_file regfile(.clk(clk),
                          .rstn(rstn),
                          .raddr0(rs0),
                          .raddr1(rs1),
                          .we(regwrite),
                          .waddr(rd),
                          .wdata(regwdata),
                          .rdata0(rs0data),
                          .rdata1(rs1data));

    // hazard unit 
    hazard_unit hazard_unit(.rs0D(rs0),
                            .rs1D(rs1),
                            .rdE(rdE),
                            .rdM(rdM),
                            .regwriteE(regwriteE),
                            .memreadE(memreadE),
                            .regwriteM(regwriteM),
                            .forward0(forward0),
                            .forward1(forward1),
                            .lwstall(lwstall));

    // branch jump unit
    // stall && flush  signal
    always_ff @(posedge clk) begin
        if (~rstn)  begin
            pc <= 32'b0;
        end else begin
            if (fetch_enable) begin // ~stall && ~flush
                pc <= (i_jal ? pc_jal : pc) + 32'b100;
            end else if (branchjump_miss) begin // branchjump miss
                pc <= pcnext + 32'b100;
            end 
            // othewise -> stall
        end
    end
    
    // stall & flush
    assign fetch_enable = ~lwstall && ~branchjump_miss && exec_fin && memory_fin;
    assign fetch_rstn = 1'b1;

    assign decode_enable = ~lwstall && ~branchjump_miss && exec_fin && memory_fin;
    assign decode_rstn = ~branchjump_miss;

    assign exec_enable = ~lwstall && ~branchjump_miss && exec_fin && memory_fin;
    assign exec_rstn = ~( (branchjump_miss || lwstall) && memory_enable );

    assign memory_enable = exec_fin && memory_fin; 
    assign memory_rstn = 1'b1;

    assign write_enable = memory_fin;
    assign write_rstn = 1'b1;

endmodule
`default_nettype wire
