`timescale 1ns / 1ps
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
    input wire [31:0] src0,
    input wire [31:0] src1,
    input wire [3:0] fpuop, 
    output logic [31:0] result
    );
    
    logic [31:0] fadd_res, fsub_res, fmul_res, fdiv_res, fsqrt_res,
                 fsgnj_res, fsgnjn_res, fsgnjx_res, 
                 feq_res, fle_res, flt_res,
                 fcvtws_res, fcvtsw_res; 
    
    // fpu's module
    // fadd fadd_0(src0, src1, fadd_res); 
    // ...

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
