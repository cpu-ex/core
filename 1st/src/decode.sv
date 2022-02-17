
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
    input wire [31:0] instr1,
    input wire prediction,
    input wire [8:0] pc_xor_global_history,

    output Inst inst,
    output logic [31:0] rdata0,
    output logic [31:0] rdata1);
     
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
                  .instr1(instr1),
                  .imm(inst.imm));

    assign rs0 = rs0_;
    assign rs1 = rs1_;
    assign inst.rs0 = rs0_;
    assign inst.rs1 = rs1_;
    assign inst.rd = rd_;
    assign inst.pc = pc;
    assign inst.prediction = prediction;
    assign inst.pc_xor_global_history = pc_xor_global_history;
        
    // forwarding
    assign rdata0 = forward0 == 2'b00 ? rs0data:
                    forward0 == 2'b01 ? regwdataE:
                    regwdataM;

    // forwarding
    assign rdata1 = forward1 == 2'b00 ? rs1data:
                    forward1 == 2'b01 ? regwdataE:
                    regwdataM;

    assign fin = 1'b1;

endmodule

`default_nettype wire
