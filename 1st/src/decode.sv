// `default_nettype none
// `timescale 1ns / 1ps
// `include "def.sv"

// module decode
//    (input wire clk,
//     input wire rstn,
//     input wire enable,
//     output wire fin,

//     output logic [5:0] rs0,
//     output logic [5:0] rs1,
//     input wire [31:0] rs0data,
//     input wire [31:0] rs1data,
//     input wire [31:0] regwdataE,
//     input wire [31:0] regwdataM,
//     input wire [1:0] forward0,
//     input wire [1:0] forward1,

//     input wire [31:0] pc,
//     input wire [31:0] instr,

//     output Inst inst,
//     output logic [31:0] rdata0,
//     output logic [31:0] rdata1,
//     output logic [31:0] src0,
//     output logic [31:0] src1);
     
//     logic rs0flag, rs1flag, rdflag;
//     wire [6:0] opcode = instr[6:0];
//     wire [2:0] funct3 = instr[14:12];
//     wire [6:0] funct7 = instr[31:25];
//     wire [5:0] rs0_ = {rs0flag, instr[19:15]};
//     wire [5:0] rs1_ = {rs1flag, instr[24:20]};
//     wire [5:0] rd_ = {rdflag, instr[11:7]};

//     // controler
//     single_cycle_control controler(.opcode(opcode),
//                                    .funct3(funct3),
//                                    .funct7(funct7),
//                                    .memtoreg(inst.memtoreg),
//                                    .memwrite(inst.memwrite),
//                                    .memread(inst.memread),
//                                    .imemwrite(inst.imemwrite),
//                                    .branchjump(inst.branchjump),
//                                    .aluop(inst.aluop),
//                                    .fpuop(inst.fpuop),
//                                    .branchop(inst.branchop),
//                                    .src0(inst.src0),
//                                    .src1(inst.src1),
//                                    .regwrite(inst.regwrite),
//                                    .aluorfpu(inst.aluorfpu),
//                                    .rs0flag(rs0flag),
//                                    .rs1flag(rs1flag),
//                                    .rdflag(rdflag));

//     // imm
//     immgen immgen(.instr(instr),
//                   .imm(inst.imm));

//     assign rs0 = rs0_;
//     assign rs1 = rs1_;
//     assign inst.rs0 = rs0_;
//     assign inst.rs1 = rs1_;
//     assign inst.rd = rd_;
//     assign inst.pc = pc;

//     logic [31:0] src0_, src1_;

//     // forwarding
//     always_comb begin
//         unique case (forward0)
//             2'b00: rdata0 = rs0data;
//             2'b01: rdata0 = regwdataE;
//             2'b10: rdata0 = regwdataM;
//         endcase
//     end

//     // forwarding
//     always_comb begin
//         unique case (forward1)
//             2'b00: rdata1 = rs1data;
//             2'b01: rdata1 = regwdataE;
//             2'b10: rdata1 = regwdataM;
//         endcase
//     end    

//     mux4 src0_mux4(.data0(rs0data),
//                    .data1(32'b0),
//                    .data2(pc),
//                    .data3(32'b0),
//                    .s(inst.src0),
//                    .data(src0_));

//     mux4 src1_mux4(.data0(rs1data),
//                    .data1(32'b100),
//                    .data2(inst.imm),
//                    .data3(32'b0),
//                    .s(inst.src1),
//                    .data(src1_));
    
//     mux2 src0mux2(.data0(src0_),
//                   .data1(rdata0),
//                   .s(inst.src0 == 2'b0),
//                   .data(src0));

//     mux2 src1mux2(.data0(src1_),
//                   .data1(rdata1),
//                   .s(inst.src1 == 2'b0),
//                   .data(src1));

//     // inst.src0 == 2'b00 -> (forward0 == 2'b00 -> rs0data
//     //                        forward0 == 2'b01 -> regwdataE
//     //                        forward0 == 2'b10 -> regwdataM)
//     // else -> src0_

//     assign fin = 1'b1;

// endmodule
// `default_nettype wire

`default_nettype none
`timescale 1ns / 1ps
`include "def.sv"

module decode
   (input wire clk,
    input wire rstn,
    input wire enable,
    output wire fin,

    output logic [5:0] rs0,
    output logic [5:0] rs1,
    input wire [31:0] rs0data,
    input wire [31:0] rs1data,
    input wire [31:0] regwdataE,
    input wire [31:0] regwdataM,
    input wire [1:0] forward0,
    input wire [1:0] forward1,

    input wire [31:0] pc,
    input wire [31:0] instr,

    output Inst inst,
    output logic [31:0] rdata0,
    output logic [31:0] rdata1,
    output logic [31:0] src0,
    output logic [31:0] src1);
    //output logic flag
     
    logic rs0flag, rs1flag, rdflag;
    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];
    wire [5:0] rs0_ = {rs0flag, instr[19:15]};
    wire [5:0] rs1_ = {rs1flag, instr[24:20]};
    wire [5:0] rd_ = {rdflag, instr[11:7]};

    // controler
    single_cycle_control controler(.opcode(opcode),
                                   .funct3(funct3),
                                   .funct7(funct7),
                                   .memtoreg(inst.memtoreg),
                                   .memwrite(inst.memwrite),
                                   .memread(inst.memread),
                                   .imemwrite(inst.imemwrite),
                                   .branchjump(inst.branchjump),
                                   .aluop(inst.aluop),
                                   .fpuop(inst.fpuop),
                                   .branchop(inst.branchop),
                                   .src0(inst.src0),
                                   .src1(inst.src1),
                                   .regwrite(inst.regwrite),
                                   .aluorfpu(inst.aluorfpu),
                                   .rs0flag(rs0flag),
                                   .rs1flag(rs1flag),
                                   .rdflag(rdflag));

    // imm
    immgen immgen(.instr(instr),
                  .imm(inst.imm));

    assign rs0 = rs0_;
    assign rs1 = rs1_;
    assign inst.rs0 = rs0_;
    assign inst.rs1 = rs1_;
    assign inst.rd = rd_;
    assign inst.pc = pc;
        
    // forwarding
    mux4 rdata0mux4(.data0(rs0data),
                    .data1(regwdataE),
                    .data2(regwdataM),
                    .data3(32'b0),
                    .s(forward0),
                    .data(rdata0));

    // forwarding
    mux4 rdata1mux4(.data0(rs1data),
                    .data1(regwdataE),
                    .data2(regwdataM),
                    .data3(32'b0),
                    .s(forward1),
                    .data(rdata1));

    mux4 src0mux4(.data0(rdata0),
                  .data1(32'b0),
                  .data2(pc),
                  .data3(32'b0),
                  .s(inst.src0),
                  .data(src0));

    mux4 src1mux4(.data0(rdata1),
                  .data1(32'b100),
                  .data2(inst.imm),
                  .data3(32'b0),
                  .s(inst.src1),
                  .data(src1));

    // // branch flag calculate
    // branch_unit branch(.src0(src0),
    //                    .src1(src1),
    //                    .branchop(inst.branchop),
    //                    .flag(flag));

    assign fin = 1'b1;

endmodule


module branch_unit(
    input wire [31:0] src0,
    input wire [31:0] src1,
    input wire [1:0] branchop, 
    output logic flag
    );

    always_comb begin
        unique case (branchop)
            2'b00: flag = src0 == src1 ? 1'b1 : 1'b0; // BEQ
            2'b01: flag = src0 == src1 ? 1'b0 : 1'b1;  // BNE
            2'b10: flag = $signed(src0) <  $signed (src1) ? 1'b1 : 1'b0; // BLT
            2'b11: flag = $signed(src0) >= $signed (src1) ? 1'b1 : 1'b0; // BGE
            default: flag = 1'b0;
        endcase
    end

endmodule
`default_nettype wire
