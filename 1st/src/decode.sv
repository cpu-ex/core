
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
    output logic [5:0] reg2,
    output logic [5:0] reg3,
    output logic [5:0] reg4,
    output logic [5:0] reg5,
    output logic i_vsw,
    input wire [31:0] rs0data,
    input wire [31:0] rs1data,
    input wire [31:0] reg2data,
    input wire [31:0] reg3data,
    input wire [31:0] reg4data,
    input wire [31:0] reg5data,
    input wire [31:0] regwdataE,
    input wire [31:0] regwdataM,
    input wire [31:0] regwdataM2,
    input wire [31:0] regwdataM3,
    input wire [31:0] regwdataM4,
    input wire [31:0] regwdataM5,
    input wire [2:0] forward0,
    input wire [2:0] forward1,
    input wire [2:0] forward2,
    input wire [2:0] forward3,
    input wire [2:0] forward4,
    input wire [2:0] forward5,

    input wire [31:0] pc,
    input wire [31:0] instr,
    input wire [31:0] instr1,
    input wire prediction,
    input wire [7:0] pc_xor_global_history,

    output Inst inst,
    output logic [31:0] rdata0,
    output logic [31:0] rdata1,
    output logic [31:0] rdata2,
    output logic [31:0] rdata3,
    output logic [31:0] rdata4,
    output logic [31:0] rdata5);
     
    logic rs0flag, rs1flag, rdflag;
    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];
    wire [5:0] rs0_ = {rs0flag, instr[19:15]};
    wire [5:0] rs1_ = {rs1flag, instr[24:20]};
    wire [5:0] rd_ = {rdflag, instr[11:7]};
    assign reg2 = instr1[31:26];
    assign reg3 = instr1[25:20];
    assign reg4 = instr1[19:14];
    assign reg5 = instr1[13:8];

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
                                   .vec_regwrite(inst.vec_regwrite),
                                   .aluorfpu(inst.aluorfpu),
                                   .rs0flag(rs0flag),
                                   .rs1flag(rs1flag),
                                   .rdflag(rdflag),
                                   .vecmode(inst.vecmode),
                                   .i_vsw(i_vsw));

    // imm
    immgen immgen(.instr(instr),
                  .imm(inst.imm));

    assign rs0 = rs0_;
    assign rs1 = rs1_;
    assign inst.rs0 = rs0_;
    assign inst.rs1 = rs1_;
    assign inst.rd = rd_;
    assign inst.pc = pc;
    assign inst.prediction = prediction;
    assign inst.pc_xor_global_history = pc_xor_global_history;
    assign inst.reg2 = reg2;
    assign inst.reg3 = reg3;
    assign inst.reg4 = reg4;
    assign inst.reg5 = reg5;
    assign inst.vecmask = instr[10:7];

    // function [31:0] select_by_forward(
    //     input [2:0] forward,
    //     input [31:0] reg_file_data
    // );
    // begin
    //     (* parallel_case *) unique case (forward)
    //     3'b000: select_by_forward = reg_file_data;
    //     3'b001: select_by_forward = regwdataE;
    //     3'b010: select_by_forward = regwdataM;
    //     3'b011: select_by_forward = regwdataM2;
    //     3'b100: select_by_forward = regwdataM3;
    //     3'b101: select_by_forward = regwdataM4;
    //     3'b110: select_by_forward = regwdataM5;
    //     endcase
    // end
    // endfunction
        
    // forwarding
    // assign rdata0 = forward0 == 3'b000 ? rs0data:
    //                 forward0 == 3'b001 ? regwdataE:
    //                 forward0 == 3'b010 ? regwdataM:
    //                 forward0 == 3'b011 ? regwdataM2:
    //                 forward0 == 3'b100 ? regwdataM3:
    //                 forward0 == 3'b101 ? regwdataM4:
    //                 regwdataM5;

    // forwarding
    always_comb begin
        (* parallel_case *) unique case (forward0)
        3'b000: rdata0 = rs0data;
        3'b001: rdata0 = regwdataE;
        3'b010: rdata0 = regwdataM;
        3'b011: rdata0 = regwdataM2;
        3'b100: rdata0 = regwdataM3;
        3'b101: rdata0 = regwdataM4;
        3'b110: rdata0 = regwdataM5;
        endcase
    end

    always_comb begin
        (* parallel_case *) unique case (forward1)
        3'b000: rdata1 = rs1data;
        3'b001: rdata1 = regwdataE;
        3'b010: rdata1 = regwdataM;
        3'b011: rdata1 = regwdataM2;
        3'b100: rdata1 = regwdataM3;
        3'b101: rdata1 = regwdataM4;
        3'b110: rdata1 = regwdataM5;
        endcase
    end

    always_comb begin
        (* parallel_case *) unique case (forward2)
        3'b000: rdata2 = reg2data;
        3'b001: rdata2 = regwdataE;
        3'b010: rdata2 = regwdataM;
        3'b011: rdata2 = regwdataM2;
        3'b100: rdata2 = regwdataM3;
        3'b101: rdata2 = regwdataM4;
        3'b110: rdata2 = regwdataM5;
        endcase
    end

    always_comb begin
        (* parallel_case *) unique case (forward3)
        3'b000: rdata3 = reg3data;
        3'b001: rdata3 = regwdataE;
        3'b010: rdata3 = regwdataM;
        3'b011: rdata3 = regwdataM2;
        3'b100: rdata3 = regwdataM3;
        3'b101: rdata3 = regwdataM4;
        3'b110: rdata3 = regwdataM5;
        endcase
    end

    always_comb begin
        (* parallel_case *) unique case (forward4)
        3'b000: rdata4 = reg4data;
        3'b001: rdata4 = regwdataE;
        3'b010: rdata4 = regwdataM;
        3'b011: rdata4 = regwdataM2;
        3'b100: rdata4 = regwdataM3;
        3'b101: rdata4 = regwdataM4;
        3'b110: rdata4 = regwdataM5;
        endcase
    end

    always_comb begin
        (* parallel_case *) unique case (forward5)
        3'b000: rdata5 = reg5data;
        3'b001: rdata5 = regwdataE;
        3'b010: rdata5 = regwdataM;
        3'b011: rdata5 = regwdataM2;
        3'b100: rdata5 = regwdataM3;
        3'b101: rdata5 = regwdataM4;
        3'b110: rdata5 = regwdataM5;
        endcase
    end
    // assign rdata0 = select_by_forward(forward0, rs0data);
    // assign rdata1 = select_by_forward(forward1, rs1data);
    // assign rdata2 = select_by_forward(forward2, reg2data);
    // assign rdata3 = select_by_forward(forward3, reg3data);
    // assign rdata4 = select_by_forward(forward4, reg4data);
    // assign rdata5 = select_by_forward(forward5, reg5data);

    // todo 
    // sw reg2, reg3, reg4, reg5 forwarding
    // function ka
    // assign rdata2 = reg2data;
    // assign rdata3 = reg3data;
    // assign rdata4 = reg4data;
    // assign rdata5 = reg5data;

    assign fin = 1'b1;

endmodule

`default_nettype wire
