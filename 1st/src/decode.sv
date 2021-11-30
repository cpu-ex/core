`include "def.sv"


module decode
   (/* verilator lint_off UNUSED */ input wire clk,
    /* verilator lint_off UNUSED */ input wire rstn,
    /* verilator lint_off UNUSED */ input wire enable,
    output wire fin,

    output logic [5:0] rs0,
    output logic [5:0] rs1,
    input logic [31:0] rs0data,
    input logic [31:0] rs1data,
    input logic [31:0] regwdataE,
    input logic [31:0] regwdataM,
    input logic [1:0] forward0,
    input logic [1:0] forward1,

    input logic [31:0] pc,
    input logic [31:0] instr,

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

    assign fin = 1'b1;

endmodule