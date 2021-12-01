
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


module fpu(
    input wire clk,
    input wire rstn,
    /* verilator lint_off UNUSED */ input wire [31:0] src0,
    /* verilator lint_off UNUSED */ input wire [31:0] src1,
    input wire [3:0] fpuop, 
    output logic [31:0] result
    );
    
    logic [31:0] fadd_res, fsub_res, fmul_res, fdiv_res, fsqrt_res,
                 fsgnj_res, fsgnjn_res, fsgnjx_res, 
                 feq_res, fle_res, flt_res,
                 fcvtws_res, fcvtsw_res; 
    logic overflow;

    fadd fadd(.clk(clk), .rstn(rstn), .x1(src0), .x2(src1), .y(fadd_res), .overflow(overflow));
    fsub fsub(.clk(clk), .rstn(rstn), .x1(src0), .x2(src1), .y(fsub_res), .ovf(overflow));
    fmul fmul(.clk(clk), .rstn(rstn), .x1(src0), .x2(src1), .y(fmul_res));
    // fdiv
    // fsqrt
    fsgnj fsgnj(.clk(clk), .rstn(rstn), .x1(src0), .x2(src1), .y(fsgnj_res));
    fsgnjn fsgnjn(.clk(clk), .rstn(rstn), .x1(src0), .x2(src1), .y(fsgnjn_res));
    fsgnjx fsgnjx(.clk(clk), .rstn(rstn), .x1(src0), .x2(src1), .y(fsgnjx_res));
    feq feq(.clk(clk), .rstn(rstn), .x1(src0), .x2(src1), .y(feq_res));
    fle fle(.clk(clk), .rstn(rstn), .x1(src0), .x2(src1), .y(fle_res));
    flt flt(.clk(clk), .rstn(rstn), .x1(src0), .x2(src1), .y(flt_res));
    fcvtsw fcvtsw(.clk(clk), .rstn(rstn), .x(src0), .y(fcvtsw_res));
    fcvtws fcvtws(.clk(clk), .rstn(rstn), .x(src0), .y(fcvtws_res));

    always_comb begin
        case (fpuop)
            4'b0000: result = fadd_res; 
            4'b0001: result = fsub_res; 
            4'b0010: result = fmul_res; 
            4'b0011: result = fdiv_res; 
            4'b0100: result = fsqrt_res; 
            4'b0101: result = fsgnj_res; 
            4'b0110: result = fsgnjn_res; 
            4'b0111: result = fsgnjx_res; 
            4'b1000: result = feq_res; 
            4'b1001: result = fle_res; 
            4'b1010: result = flt_res; 
            4'b1011: result = fcvtws_res; 
            4'b1100: result = fcvtsw_res;
            default: result = 32'b0; 
        endcase
    end
endmodule
