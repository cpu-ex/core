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
    logic [2:0] forward0;
    logic [2:0] forward1;
    logic [2:0] forward2;
    logic [2:0] forward3;
    logic [2:0] forward4;
    logic [2:0] forward5;
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

    logic [31:0] pc_predicated;
    logic [7:0] pc_xor_global_history;
    logic [31:0] imemraddr;
    logic [31:0] imemrdata;
    logic [31:0] imemrdata1; 
    logic [31:0] pc_FD;
    logic [31:0] instr_FD;
    logic [31:0] instr1_FD;
    logic [7:0] pc_xor_global_history_FD;

    wire prediction, update, taken; 
    GShare_predictor Gshare_predictor(.clk(clk),
                                      .rstn(rstn),
                                      .pc_predict(imemraddr),
                                      .prediction(prediction),
                                      .pc_xor_global_history(pc_xor_global_history),
                                      .index_update(inst_DE_reg.pc_xor_global_history),
                                      .update(update),
                                      .taken(taken));

    fetch fetch(.clk(clk),
                .rstn(rstn && fetch_rstn),
                .enable(fetch_enable),
                .fin(fetch_fin),
                .imemraddr(imemraddr),
                .imemrdata(imemrdata),
                .imemrdata1(imemrdata1),
                .branchjump_miss(branchjump_miss),
                .pc_predicated(pc_predicated),
                .prediction(prediction),
                .pc_xor_global_history(pc_xor_global_history),
                .pc(pc),
                .pcnext(pcnext),
                .pc_out(pc_FD),
                .instr(instr_FD),
                .instr1(instr1_FD),
                .pc_xor_global_history_out(pc_xor_global_history_FD));

    // FD
    logic [31:0] pc_FD_reg;
    (* max_fanout = 50 *) logic [31:0] instr_FD_reg;
    logic [31:0] instr1_FD_reg;
    logic prediction_FD_reg;
    logic [7:0] pc_xor_global_history_FD_reg;
    always_ff @(posedge clk) begin
        if (~(rstn && decode_rstn)) begin
            pc_FD_reg <= 32'b0;
            instr_FD_reg <= 32'b0;
            instr1_FD_reg <= 32'b0;
            prediction_FD_reg <= 1'b0;
            pc_xor_global_history_FD_reg <= 8'b0;
        end else begin
            if (decode_enable) begin
                pc_FD_reg <= pc_FD;
                instr_FD_reg <= instr_FD;
                instr1_FD_reg <= instr1_FD;
                prediction_FD_reg <= prediction;
                pc_xor_global_history_FD_reg <= pc_xor_global_history_FD;
            end
        end
    end

   
    logic [5:0] rs0;
    logic [5:0] rs1;
    logic [5:0] reg2;
    logic [5:0] reg3;
    logic [5:0] reg4;
    logic [5:0] reg5;
    logic [31:0] rs0data;
    logic [31:0] rs1data;
    logic [31:0] reg2data;
    logic [31:0] reg3data;
    logic [31:0] reg4data;
    logic [31:0] reg5data;
    logic [31:0] regwdataE;
    logic [31:0] regwdataM;
    logic [31:0] regwdataM2;
    logic [31:0] regwdataM3;
    logic [31:0] regwdataM4;
    logic [31:0] regwdataM5;
    Inst inst_DE;
    logic [31:0] rdata0_DE;
    logic [31:0] rdata1_DE;
    logic [31:0] rdata2_DE;
    logic [31:0] rdata3_DE;
    logic [31:0] rdata4_DE;
    logic [31:0] rdata5_DE;
    logic flag_DE;
    logic i_vsw;

    decode decode(.clk(clk),
                   .rstn(rstn && decode_rstn),
                   .enable(decode_enable),
                   .fin(decode_fin),
                   .rs0(rs0),
                   .rs1(rs1),
                   .reg2(reg2), .reg3(reg3), .reg4(reg4), .reg5(reg5),
                   .i_vsw(i_vsw),
                   .rs0data(rs0data),
                   .rs1data(rs1data),
                   .reg2data(reg2data), .reg3data(reg3data), .reg4data(reg4data), .reg5data(reg5data),
                   .regwdataE(regwdataE),
                   .regwdataM(regwdataM),
                   .regwdataM2(regwdataM2), .regwdataM3(regwdataM3), .regwdataM4(regwdataM4), .regwdataM5(regwdataM5),
                   .forward0(forward0),
                   .forward1(forward1),
                   .forward2(forward2),
                   .forward3(forward3),
                   .forward4(forward4),
                   .forward5(forward5),
                   .pc(pc_FD_reg),
                   .instr(instr_FD_reg),
                   .instr1(instr1_FD_reg),
                   .prediction(prediction_FD_reg),
                   .pc_xor_global_history(pc_xor_global_history_FD_reg),
                   .inst(inst_DE),
                   .rdata0(rdata0_DE),
                   .rdata1(rdata1_DE),
                   .rdata2(rdata2_DE),
                   .rdata3(rdata3_DE),
                   .rdata4(rdata4_DE),
                   .rdata5(rdata5_DE),
                   .flag(flag_DE));

    // DE
    (* max_fanout = 50 *) Inst inst_DE_reg;
    (* max_fanout = 50 *) logic [31:0] rdata0_DE_reg;
    (* max_fanout = 50 *) logic [31:0] rdata1_DE_reg;
    logic [31:0] rdata2_DE_reg;
    logic [31:0] rdata3_DE_reg;
    logic [31:0] rdata4_DE_reg;
    logic [31:0] rdata5_DE_reg;
    logic flag_DE_reg;
    always_ff @(posedge clk) begin
        if (~(rstn && exec_rstn)) begin
            inst_DE_reg <= '{default : '0, fpuop: 4'b1101};
            rdata0_DE_reg <= 32'b0;
            rdata1_DE_reg <= 32'b0;
            rdata2_DE_reg <= 32'b0;
            rdata3_DE_reg <= 32'b0;
            rdata4_DE_reg <= 32'b0;
            rdata5_DE_reg <= 32'b0;
            flag_DE_reg <= 1'b0;
        end else begin
            if (exec_enable) begin
                inst_DE_reg <= inst_DE;
                rdata0_DE_reg <= rdata0_DE;
                rdata1_DE_reg <= rdata1_DE;
                rdata2_DE_reg <= rdata2_DE;
                rdata3_DE_reg <= rdata3_DE;
                rdata4_DE_reg <= rdata4_DE;
                rdata5_DE_reg <= rdata5_DE;
                flag_DE_reg <= flag_DE;
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
    logic [127:0] vec_data_EM;
    assign regwdataE = result_EM;

    exec exec (.clk(clk),
               .rstn(rstn && exec_rstn),
               .enable(exec_enable),
               .fin(exec_fin),
               .rd(rdE),
               .regwrite(regwriteE),
               .memread(memreadE),
               .branchjump_miss(branchjump_miss),
               .taken(taken),
               .update(update),
               .rdata0(rdata0_DE_reg),
               .rdata1(rdata1_DE_reg),
               .rdata2(rdata2_DE_reg),
               .rdata3(rdata3_DE_reg),
               .rdata4(rdata4_DE_reg),
               .rdata5(rdata5_DE_reg),
               .inst(inst_DE_reg),
               .flag(flag_DE_reg),
               .pcnext(pcnext),
               .inst_out(inst_EM),
               .aluresult(aluresult_EM),
               .result(result_EM),
               .rdata1_out(rdata1_EM),
               .vec_data(vec_data_EM));


    logic [5:0] rdM;
    logic [5:0] rdM2;
    logic [5:0] rdM3;
    logic [5:0] rdM4;
    logic [5:0] rdM5;
    logic regwriteM;
    logic vec_regwriteM;
    logic imemwrite;
    logic [31:0] imemwaddr;
    logic [31:0] imemwdata;

    Inst inst_MW;
    logic [31:0] regwdata_MW;
    logic [127:0] vec_memrdata_MW;
    assign regwdataM = regwdata_MW;
    assign regwdataM2 = vec_memrdata_MW[31:0];
    assign regwdataM3 = vec_memrdata_MW[63:32];
    assign regwdataM4 = vec_memrdata_MW[95:64];
    assign regwdataM5 = vec_memrdata_MW[127:96];

    memory memory(.clk(clk),
                  .rstn(rstn && memory_rstn),
                  .enable(memory_enable),
                  .fin(memory_fin),
                  .rd(rdM),
                  .rd2(rdM2), .rd3(rdM3), .rd4(rdM4), .rd5(rdM5),
                  .regwrite(regwriteM),
                  .vec_regwrite(vec_regwriteM),
                  .imemwrite(imemwrite),
                  .imemwaddr(imemwaddr),
                  .imemwdata(imemwdata),
                  .addr(addr_cache),
                  .wdata(wdata_cache),
                  .rdata(rdata_cache),
                  .write_enable(write_enable_cache),
                  .read_enable(read_enable_cache),
                  .miss(miss_cache),
                //   .vec_wdata(),
                //   .vec_rdata(),
                //   .vec_mode(),
                //   .vec_mask(),
                  .inst(inst_EM),
                  .aluresult(aluresult_EM),
                  .result(result_EM),
                  .rdata1(rdata1_EM),
                  .vec_data(vec_data_EM),
                  .uart_rx_data(uart_rx_data),
                  .empty(empty),
                  .full(full),
                  .inst_out(inst_MW),
                  .regwdata(regwdata_MW),
                  .vec_memrdata(vec_memrdata_MW),
                  .uart_rd_en(uart_rd_en),
                  .uart_wr_en(uart_wr_en),
                  .uart_tx_data(uart_tx_data));

    // MW
    Inst inst_MW_reg;
    logic [31:0] regwdata_MW_reg;
    logic [127:0] vec_memrdata_MW_reg;
    always_ff @(posedge clk) begin
        if (~(rstn && write_rstn)) begin
            inst_MW_reg <= '{default : '0, fpuop : 4'b1101};
            regwdata_MW_reg <= 32'b0;
            vec_memrdata_MW_reg <= 128'b0;
        end else begin
            if (write_enable) begin
                inst_MW_reg <= inst_MW;
                regwdata_MW_reg <= regwdata_MW;
                vec_memrdata_MW_reg <= vec_memrdata_MW;
            end
        end
    end 
 
    logic [31:0] regwdata;
    logic [31:0] regwdata2;
    logic [31:0] regwdata3;
    logic [31:0] regwdata4;
    logic [31:0] regwdata5;
    logic regwrite;
    logic vec_regwrite;
    logic [5:0] rd;
    logic [5:0] rd2;
    logic [5:0] rd3;
    logic [5:0] rd4;
    logic [5:0] rd5;

    write write(.clk(clk),
                .rstn(rstn && write_rstn),
                .enable(write_enable),
                .fin(write_fin),
                .regwdata(regwdata), .regwdata2(regwdata2), .regwdata3(regwdata3), .regwdata4(regwdata4), .regwdata5(regwdata5),
                .regwrite(regwrite), 
                .vec_regwrite(vec_regwrite),
                .rd(rd), .rd2(rd2), .rd3(rd3), .rd4(rd4), .rd5(rd5),
                .inst(inst_MW_reg),
                .regwdata_in(regwdata_MW_reg),
                .vec_regwdata_in(vec_memrdata_MW_reg));
                
    // inst memory
    logic [14:0] addr;
    assign addr = imemwrite ? imemwaddr[16:2] : (imemraddr[16:2] + 15'b1);
    // for 64bit instruction, we need imemdata[imemraddr+1]
    // for swi (store word instruction), we need imemwaddr, if imemwrite = 1'b1
    // we need swi instruction, only in bootloader 
    ram_block_inst #(.ADDR_WIDTH(15),
                   .DATA_WIDTH(32))
    imem(.clk(clk),
         .addr0(imemraddr[16:2]),
         .enable0(1'b1),
         .write_enable0(1'b0),
         .read_data0(imemrdata),
         .write_data0(32'b0),
         .addr1(addr),
         .enable1(1'b1),
         .write_enable1(imemwrite),
         .read_data1(imemrdata1),
         .write_data1(imemwdata));

    // reg file
    register_file regfile(.clk(clk),
                          .rstn(rstn),
                          .raddr0(rs0),
                          .raddr1(rs1),
                          .raddr2(reg2),
                          .raddr3(reg3),
                          .raddr4(reg4),
                          .raddr5(reg5),                          
                          .we(regwrite),
                          .vecwe(vec_regwrite),
                          .waddr(rd),
                          .waddr2(rd2),
                          .waddr3(rd3),
                          .waddr4(rd4),
                          .waddr5(rd5),
                          .wdata(regwdata),
                          .wdata2(regwdata2),
                          .wdata3(regwdata3),
                          .wdata4(regwdata4),
                          .wdata5(regwdata5),
                          .rdata0(rs0data),
                          .rdata1(rs1data),
                          .rdata2(reg2data),
                          .rdata3(reg3data),
                          .rdata4(reg4data),
                          .rdata5(reg5data));

    // hazard unit 
    hazard_unit hazard_unit(.rs0D(rs0),
                            .rs1D(rs1),
                            .rs2D(reg2),
                            .rs3D(reg3),
                            .rs4D(reg4),
                            .rs5D(reg5),
                            .rdE(rdE),
                            .rdE2(inst_DE_reg.reg2), 
                            .rdE3(inst_DE_reg.reg3), 
                            .rdE4(inst_DE_reg.reg4), 
                            .rdE5(inst_DE_reg.reg5),
                            .rdM(rdM),
                            .rdM2(rdM2),
                            .rdM3(rdM3),
                            .rdM4(rdM4),
                            .rdM5(rdM5),
                            .i_vswD(i_vsw),
                            .regwriteE(regwriteE),
                            .vec_regwriteE(inst_DE_reg.vec_regwrite),
                            .memreadE(memreadE),
                            .regwriteM(regwriteM),
                            .vec_regwriteM(vec_regwriteM),
                            .forward0(forward0),
                            .forward1(forward1),
                            .forward2(forward2),
                            .forward3(forward3),
                            .forward4(forward4),
                            .forward5(forward5),
                            .lwstall(lwstall));

    // branch jump unit
    // stall && flush  signal
    always_ff @(posedge clk) begin
        if (~rstn)  begin
            pc <= 32'b0;
        end else begin
            if (fetch_enable) begin // ~stall && ~flush
                pc <= pc_predicated + 32'b100;
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
