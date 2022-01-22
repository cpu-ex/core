`default_nettype none
`timescale 1ns / 1ps
`include "def.sv"

module exec
   (input wire clk,
    input wire rstn,
    input wire enable,
    output wire fin,

    output logic [5:0] rd,
    output logic regwrite,
    output logic memread,
    output logic branchjump_miss,

    input wire [31:0] src0,
    input wire [31:0] src1,
    input wire [31:0] rdata0,
    input wire [31:0] rdata1,
    //input wire flag,
    input Inst inst,

    output logic [31:0] pcnext,
    output Inst inst_out,
    output logic [31:0] aluresult,
    output logic [31:0] result,
    output logic [31:0] rdata1_out);

    // alu
    logic [31:0] aluresult_;
    alu alu(.src0(src0),
            .src1(src1),
            .aluop(inst.aluop),
            .result(aluresult_));

    // fpu
    logic [31:0] fpuresult;
    logic fpu_fin;
    fpu fpu(.clk(clk),
            .rstn(rstn),
            .src0(src0),
            .src1(src1),
            .fpuop(inst.fpuop),
            .result(fpuresult),
            .fin(fpu_fin));
    
    // branch
    logic flag;
    branch_unit branch_unit(.src0(src0),
                            .src1(src1),
                            .branchop(inst.branchop),
                            .flag(flag));
    

    mux2 resultmux2(.data0(aluresult_),
                    .data1(fpuresult),
                    .s(inst.aluorfpu),
                    .data(result));

    wire [31:0] pc4 = inst.pc + 32'b100; 
    wire [31:0] pcimm = inst.pc + inst.imm; 
    wire [31:0] pcjalr = rdata0 + inst.imm;
    pc_control pc_control(.branchjump(inst.branchjump),
                          .flag(flag),
                          .pc4(pc4),
                          .pcimm(pcimm),
                          .pcjalr(pcjalr),
                          .pcnext(pcnext));
    
    assign rd = inst.rd;
    assign regwrite = inst.regwrite;
    assign memread = inst.memread;
    assign branchjump_miss = inst.branchjump == 2'b01 ? (flag != 1'b0): // assume always untaken 
                             inst.branchjump == 2'b11 ? 1'b1: // JALR
                             1'b0;

    assign aluresult = src0 + src1; // memaddr
    assign inst_out = inst;
    assign rdata1_out = rdata1;
    assign fin = fpu_fin;

endmodule

// module branch_unit(
//     input wire [31:0] src0,
//     input wire [31:0] src1,
//     input wire [1:0] branchop, 
//     output logic flag
//     );

//     always_comb begin
//         unique case (branchop)
//             2'b00: flag = src0 == src1 ? 1'b1 : 1'b0; // BEQ
//             2'b01: flag = src0 == src1 ? 1'b0 : 1'b1;  // BNE
//             2'b10: flag = $signed(src0) <  $signed (src1) ? 1'b1 : 1'b0; // BLT
//             2'b11: flag = $signed(src0) >= $signed (src1) ? 1'b1 : 1'b0; // BGE
//             default: flag = 32'b0;
//         endcase
//     end

// endmodule
`default_nettype wire
