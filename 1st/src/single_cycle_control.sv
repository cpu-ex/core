
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/10 16:26:09
// Design Name: 
// Module Name: single_cycle_control
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

module single_cycle_control(
    input wire [6:0] opcode, // [6,0]
    input wire [2:0] funct3, // [14,12]
    input wire [6:0] funct7, // [31,25]

    output logic memtoreg,
    output logic memwrite,
    output logic memread,
    output logic imemwrite,
    output logic [1:0] branchjump, 
    output logic [3:0] aluop,
    output logic [3:0] fpuop,
    output logic [1:0] src0,
    output logic [1:0] src1,
    output logic regwrite,
    output logic aluorfpu,
    output logic rs0flag,
    output logic rs1flag,
    output logic rdflag
    //...
    );
    
    // RV32IF
    // opcode
    localparam LUI    = 7'b0110111; // lui
    localparam AUIPC  = 7'b0010111; // auipc
    localparam JAL    = 7'b1101111; // jal 
    localparam JALR   = 7'b1100111; // jalr
    localparam BRANCH = 7'b1100011; // beq, bne, blt, bge
    localparam LOAD   = 7'b0000011; // lw
    localparam STORE  = 7'b0100011; // sw, swi
    localparam CALCI  = 7'b0010011; // addi, slti, slli, srli, srai, xori, andi, ori
    localparam CALC   = 7'b0110011; // add, sub, slt, sll, srl, sra, xor, and, or, mul, div
    localparam FLOAD  = 7'b0000111; // fl
    localparam FSTORE = 7'b0100111; // fs
    localparam F      = 7'b1010011; // fadd, fsub, fmul, fdiv, fsqrt, fsgnj, fsgnjn, fsgnjx, 
                                    // feq, fle, flt, fcvt.s.w, fcvt.w.s, fmv.w.x, fmv.x.w
    

    // RV32I
    // funct3
    localparam BEQ = 3'b000;
    localparam BNE = 3'b001;
    localparam BLT = 3'b100;
    localparam BGE = 3'b101;
    localparam LW  = 3'b010;
    localparam SW  = 3'b010;
    localparam SWI = 3'b011;
    localparam ADDSUBMUL = 3'b000; // -> funct7
    localparam SLL = 3'b001;
    localparam SR  = 3'b101; // -> funct7
    localparam SLT = 3'b010;
    localparam XORDIV = 3'b100; // -> funct7
    localparam OR  = 3'b110;
    localparam AND = 3'b111;

    // funct7 
    localparam ADD = 7'b0000000;
    localparam SUB = 7'b0100000;
    localparam SRL = 7'b0000000;
    localparam SRA = 7'b0100000;
    localparam XOR = 7'b0000000;

    // F
    // funct7
    localparam FADD   = 7'b0000000;
    localparam FSUB   = 7'b0000100;
    localparam FMUL   = 7'b0001000;
    localparam FDIV   = 7'b0001100;
    localparam FSQRT  = 7'b0101100;
    localparam FSGN   = 7'b0010000; // -> funct3
    localparam FCMP   = 7'b1010000; // -> funct3
    localparam FCVTWS = 7'b1100000;
    localparam FCVTSW = 7'b1101000;
    localparam FMVWX  = 7'b1111000;
    localparam FMVXW  = 7'b1110000;

    // funct3
    localparam FSGNJ  = 3'b000;
    localparam FSGNJN = 3'b001;
    localparam FSGNJX = 3'b010;
    localparam FEQ    = 3'b010;
    localparam FLT    = 3'b001;
    localparam FLE    = 3'b000;

    /* verilator lint_off UNUSED */ logic i_lui, i_auipc, i_jal, i_jalr, 
          i_beq, i_bne, i_blt, i_bge, 
          i_lw,
          i_sw, i_swi, 
          i_addi, i_slli, i_slti, i_xori, i_ori, i_andi, i_srli, i_srai,
          i_add, i_sub, i_sll, i_srl, i_sra, i_slt, i_xor, i_or, i_and,
          i_fload, i_fstore, 
          i_fadd, i_fsub, i_fmul, i_fdiv, i_fsqrt, 
          i_fsgnj, i_fsgnjn, i_fsgnjx, 
          i_feq, i_fle, i_flt, 
          i_fcvtws, i_fcvtsw,
          i_fmvwx, i_fmvxw;

    assign i_lui = (opcode == LUI);
    assign i_auipc = (opcode == AUIPC);
    assign i_jal = (opcode == JAL);
    assign i_jalr = (opcode == JALR);

    assign i_beq = (opcode == BRANCH && funct3 == BEQ);
    assign i_bne = (opcode == BRANCH && funct3 == BNE);
    assign i_blt = (opcode == BRANCH && funct3 == BLT);
    assign i_bge = (opcode == BRANCH && funct3 == BGE);

    assign i_lw = (opcode == LOAD && funct3 == LW);

    assign i_sw = (opcode == STORE && funct3 == SW);
    assign i_swi = (opcode == STORE && funct3 == SWI);

    assign i_addi = (opcode == CALCI && funct3 == ADDSUBMUL); // subi ,muli don't exist
    assign i_slli = (opcode == CALCI && funct3 == SLL);
    assign i_slti = (opcode == CALCI && funct3 == SLT);
    assign i_xori = (opcode == CALCI && funct3 == XORDIV);
    assign i_ori = (opcode == CALCI && funct3 == OR);
    assign i_andi = (opcode == CALCI && funct3 == AND);
    assign i_srli = (opcode == CALCI && funct3 == SR && funct7 == SRL);
    assign i_srai = (opcode == CALCI && funct3 == SR && funct7 == SRA);

    assign i_add = (opcode == CALC && funct3 == ADDSUBMUL && funct7 == ADD);
    assign i_sub = (opcode == CALC && funct3 == ADDSUBMUL && funct7 == SUB);
    assign i_sll = (opcode == CALC && funct3 == SLL);
    assign i_srl = (opcode == CALC && funct3 == SR && funct7 == SRL);
    assign i_sra = (opcode == CALC && funct3 == SR && funct7 == SRA);
    assign i_slt = (opcode == CALC && funct3 == SLT);
    assign i_xor = (opcode == CALC && funct3 == XORDIV && funct7 == XOR);
    assign i_or = (opcode == CALC && funct3 == OR);
    assign i_and = (opcode == CALC && funct3 == AND);

    assign i_fload = (opcode == FLOAD);
    assign i_fstore = (opcode == FSTORE);

    assign i_fadd = (opcode == F && funct7 == FADD);
    assign i_fsub = (opcode == F && funct7 == FSUB);
    assign i_fmul = (opcode == F && funct7 == FMUL);
    assign i_fdiv = (opcode == F && funct7 == FDIV);
    assign i_fsqrt = (opcode == F && funct7 == FSQRT);
    assign i_fsgnj = (opcode == F && funct7 == FSGN && funct3 == FSGNJ);
    assign i_fsgnjn = (opcode == F && funct7 == FSGN && funct3 == FSGNJN);
    assign i_fsgnjx = (opcode == F && funct7 == FSGN && funct3 == FSGNJX);
    assign i_feq = (opcode == F && funct7 == FCMP && funct3 == FEQ);
    assign i_fle = (opcode == F && funct7 == FCMP && funct3 == FLE);
    assign i_flt = (opcode == F && funct7 == FCMP && funct3 == FLT);
    assign i_fcvtws = (opcode == F && funct7 == FCVTWS);
    assign i_fcvtsw = (opcode == F && funct7 == FCVTSW);
    assign i_fmvwx = (opcode == F && funct7 == FMVWX);
    assign i_fmvxw = (opcode == F && funct7 == FMVXW);

    // memtoreg
    // 1'b0 -> result (alu or fpu)
    // 1'b1 -> memrdata
    assign memtoreg = (i_lw || i_fload);

    // memwrite
    // 1'b0 -> don't write
    // 1'b1 -> write
    assign memwrite = (i_sw || i_fstore);

    // memread
    // 1'b0 -> don't read
    // 1'b1 -> read
    assign memread = (i_lw || i_fload);

    // imemwrite
    // 1'b0 -> don't write
    // 1'b1 -> write
    assign imemwrite = i_swi;

    // branchjump
    // 2'b00 -> pc += 4
    // 2'b01 -> branch
    // 2'b10 -> pc += (signed)imm (JAL)
    // 2'b11 -> pc = rdata0 + (signed)imm (JALR)
    assign branchjump = (opcode == BRANCH) ? 2'b01:
                        i_jal ? 2'b10:
                        i_jalr ? 2'b11:
                        2'b00;
    
    // aluop
    // 4'b0000 -> +
    // 4'b0001 -> -
    // 4'b0010 -> slt
    // 4'b0011 -> ^
    // 4'b0100 -> &
    // 4'b0101 -> |
    // 4'b0110 -> <<
    // 4'b0111 -> >>
    // 4'b1000 -> >>>
    // 4'b1001 -> bne
    // 4'b1010 -> blt
    // 4'b1011 -> bge
    // default -> 
    assign aluop = (i_sub || i_beq)  ? 4'b0001:
                   (i_slt || i_slti) ? 4'b0010:
                   (i_xor || i_xori) ? 4'b0011:
                   (i_and || i_andi) ? 4'b0100:
                   (i_or  || i_ori)  ? 4'b0101:
                   (i_sll || i_slli) ? 4'b0110:
                   (i_srl || i_srli) ? 4'b0111:
                   (i_sra || i_srai) ? 4'b1000:
                   i_bne ? 4'b1001:
                   i_blt ? 4'b1010:
                   i_bge ? 4'b1011:
                   4'b0000;

    // fpuop
    // 4'b0000 -> fadd
    // 4'b0001 -> fsub
    // 4'b0010 -> fmul
    // 4'b0011 -> fdiv
    // 4'b0100 -> fsqrt
    // 4'b0101 -> fsgnj
    // 4'b0110 -> fsgnjn
    // 4'b0111 -> fsgnjx
    // 4'b1000 -> feq
    // 4'b1001 -> fle
    // 4'b1010 -> flt
    // 4'b1011 -> fcvtws
    // 4'b1100 -> fcvtsw
    // 4'b1101 -> default
    assign fpuop = i_fadd ? 4'b0000:
                   i_fsub ? 4'b0001:
                   i_fmul ? 4'b0010:
                   i_fdiv ? 4'b0011:
                   i_fsqrt ? 4'b0100: 
                   i_fsgnj ? 4'b0101:
                   i_fsgnjn ? 4'b0110:
                   i_fsgnjx ? 4'b0111:
                   i_feq ? 4'b1000:
                   i_fle ? 4'b1001:
                   i_flt ? 4'b1010:
                   i_fcvtws ? 4'b1011:
                   i_fcvtsw ? 4'b1100:
                   4'b1101;

    // src0
    // 2'b00 -> rdata0(from register file)
    // 2'b01 -> 0 (LUI)
    // 2'b10 -> pc
    assign src0 = i_lui ? 2'b01:
                  (i_auipc || i_jal || i_jalr) ? 2'b10:
                  2'b00;

    // src1
    // 2'b00 -> rdata1(from register file)
    // 2'b01 -> 4
    // 2'b10 -> imm
    // 2'b11 -> 0
    assign src1 = (i_jal || i_jalr) ? 2'b01:
                  (i_auipc || i_lui || i_lw || i_sw || i_swi || opcode == CALCI || i_fload || i_fstore) ? 2'b10:
                  (i_fmvwx || i_fmvxw ) ? 2'b11:
                  2'b00;

    // regwrite
    // 1'b0 -> don't write
    // 1'b1 -> write
    assign regwrite = ~(opcode == BRANCH || i_sw || i_swi || i_fstore);

    // aluorfpu
    // 1'b0 -> aluresult 
    // 1'b1 -> fpuresult
    assign aluorfpu = (opcode == F) && ~i_fmvxw && ~i_fmvwx;

    // rs0flag
    // 1'b0 -> integer register
    // 1'b1 -> floating point register
    assign rs0flag = (opcode == F) && ~i_fcvtsw && ~i_fmvwx;

    // rs1flag
    // 1'b0 -> integer register
    // 1'b1 -> floating point register
    assign rs1flag = (opcode == F) || i_fstore;

    // rdflag
    // 1'b0 -> integer register
    // 1'b1 -> floating point register
    assign rdflag = ((opcode == F) && ~i_fcvtws && ~i_fmvxw && ~i_feq && ~i_fle && ~i_flt) || i_fload;

endmodule
`default_nettype wire
