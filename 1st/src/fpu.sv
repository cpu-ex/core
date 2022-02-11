
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/24 17:45:17
// Design Name: 
// Module Name: fpu
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

module fpu(
    input wire clk,
    input wire rstn,
    input wire [31:0] src0,
    input wire [31:0] src1,
    input wire [3:0] fpuop, 
    output logic [31:0] result,
    output wire fin
    );
    
    logic [31:0] fadd_res, fsub_res, fmul_res, fdiv_res, fsqrt_res,
                 fsgnj_res, fsgnjn_res, fsgnjx_res,
                 fcvtws_res, fcvtsw_res; 

    logic feq_res, fle_res, flt_res;                 
    logic ovf0, ovf1;
    wire sign = fpuop == 4'b0000 ? src1[31] : ~src1[31];

    fadd_3 fadd(.clk(clk), .rstn(rstn), .x1(src0), .x2({sign,src1[30:0]}), .y(fadd_res), .ovf(ovf0));
    fmul_2 fmul(.clk(clk), .rstn(rstn), .x1(src0), .x2(src1), .y(fmul_res));
    fdiv_11 fdiv(.clk(clk), .rstn(rstn), .x1(src0), .x2(src1), .y(fdiv_res));
    fsqrt_7 fsqrt(.clk(clk), .rstn(rstn), .x(src0), .y(fsqrt_res));
    fsgnj fsgnj(.clk(clk), .rstn(rstn), .x1(src0), .x2(src1), .y(fsgnj_res));
    fsgnjn fsgnjn(.clk(clk), .rstn(rstn), .x1(src0), .x2(src1), .y(fsgnjn_res));
    fsgnjx fsgnjx(.clk(clk), .rstn(rstn), .x1(src0), .x2(src1), .y(fsgnjx_res));
    feq feq(.clk(clk), .rstn(rstn), .x1(src0), .x2(src1), .y(feq_res));
    fle fle(.clk(clk), .rstn(rstn), .x1(src0), .x2(src1), .y(fle_res));
    flt flt(.clk(clk), .rstn(rstn), .x1(src0), .x2(src1), .y(flt_res));
    fcvtsw_2 fcvtsw(.clk(clk), .rstn(rstn), .x(src0), .y(fcvtsw_res));
    fcvtws_1 fcvtws(.clk(clk), .rstn(rstn), .x(src0), .y(fcvtws_res));

    logic [3:0] state;

    always_ff @(posedge clk) begin
        if (~rstn) begin
            state <= 4'b0;
        end else begin
            if (state == 4'b0) begin
                if (fpuop == 4'b0000 || fpuop == 4'b0001 || fpuop == 4'b0010 || fpuop == 4'b0011 || fpuop == 4'b0100 || fpuop == 4'b1011 || fpuop == 4'b1100) begin
                    state <= state + 4'b1;
                end
            end else if (fin == 1'b1) begin
                state <= 4'b0;
            end else begin
                state <= state + 4'b1;
            end
        end
    end

    always_comb begin
        (* paralle_case *) unique case (fpuop)
            4'b0000: result = fadd_res; 
            4'b0001: result = fadd_res; 
            4'b0010: result = fmul_res; 
            4'b0011: result = fdiv_res; 
            4'b0100: result = fsqrt_res; 
            4'b0101: result = fsgnj_res; 
            4'b0110: result = fsgnjn_res; 
            4'b0111: result = fsgnjx_res; 
            4'b1000: result = {31'b0, feq_res}; 
            4'b1001: result = {31'b0, fle_res}; 
            4'b1010: result = {31'b0, flt_res}; 
            4'b1011: result = fcvtws_res; 
            4'b1100: result = fcvtsw_res;
            default: result = 32'b0; 
        endcase
    end

    assign fin = (fpuop == 4'b0000) ? (state == 4'd3 ? 1'b1 : 1'b0):
                 (fpuop == 4'b0001) ? (state == 4'd3 ? 1'b1 : 1'b0):
                 (fpuop == 4'b0010) ? (state == 4'd2 ? 1'b1 : 1'b0):
                 (fpuop == 4'b0011) ? (state == 4'd11 ? 1'b1 : 1'b0):
                 (fpuop == 4'b0100) ? (state == 4'd7 ? 1'b1 : 1'b0):
                 (fpuop == 4'b1100) ? (state == 4'd2 ? 1'b1 : 1'b0):
                 (fpuop == 4'b1011) ? (state == 4'd1 ? 1'b1 : 1'b0):
                 1'b1;
    // fin == 1'b1 <-> result is valid
endmodule

`default_nettype wire