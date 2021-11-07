`timescale 1ns / 1ps
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


module single_cycle_control(
    input wire [6:0] opcode, // [6,0]
    input wire [2:0] funct3, // [14,12]
    input wire [6:0] funct7, // [31,25]

    output logic [1:0] memtoreg,
    output logic memwrite,
    output logic memread,
    output logic imemwrite,
    output logic [1:0] branchjump, 
    output logic [3:0] aluop,
    output logic [3:0] fpuop,
    output logic alusrc0,
    output logic alusrc1,
    output logic fpusrc0,
    output logic regwrite,
    output logic fregwrite,
    output logic aluorfpu,
    output logic wordorbyte
    //...
    );
    
    // RV32IMF
    // opcode
    localparam LUI    = 7'b0110111; // lui
    localparam AUIPC  = 7'b0010111; // auipc
    localparam JAL    = 7'b1101111; // jal 
    localparam JALR   = 7'b1100111; // jalr
    localparam BRANCH = 7'b1100011; // beq, bne, blt, bge
    localparam LOAD   = 7'b0000011; // lw, lb
    localparam STORE  = 7'b0100011; // sw, sb, swi
    localparam CALCI  = 7'b0010011; // addi, slti, slli, srli, srai, xori, andi, ori
    localparam CALC   = 7'b0110011; // add, sub, slt, sll, srl, sra, xor, and, or, mul, div
    localparam FLOAD  = 7'b0000111; // fl
    localparam FSTORE = 7'b0100111; // fs
    localparam F      = 7'b1010011; // fadd, fsub, fmul, fdiv, fsqrt, fsgnj, fsgnjn, fsgnjx, feq, fle, flt, fcvt.s.w, fcvt.w.s  
    

    // RV32IM
    // funct3
    localparam BEQ = 3'b000;
    localparam BNE = 3'b001;
    localparam BLT = 3'b100;
    localparam BGE = 3'b101;
    localparam LB  = 3'b000;
    localparam LW  = 3'b010;
    localparam SB  = 3'b000;
    localparam SW  = 3'b010;
    localparam SWI = 3'b011;
    localparam ADDSUBMUL = 3'b000; // -> funct7
    localparam SLL = 3'b001;
    localparam SR  = 3'b101; // -> funct7
    localparam SLT = 3'b010;
    localparam XORDIV = 3'b100; // -> funct7
    localparam OR  = 3'b110;
    localparam AND = 3'b111;
    localparam OUT = 3'b000;
    localparam IND = 3'b001;
    localparam INI = 3'b010;
    localparam INWAIT = 3'b011;

    // funct7 
    localparam ADD = 7'b0000000;
    localparam SUB = 7'b0100000;
    localparam MUL = 7'b0000001;
    localparam SRL = 7'b0000000;
    localparam SRA = 7'b0100000;
    localparam XOR = 7'b0000000;
    localparam DIV = 7'b0000001;

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

    // funct3
    localparam FSGNJ  = 3'b000;
    localparam FSGNJN = 3'b001;
    localparam FSGNJX = 3'b010;
    localparam FEQ    = 3'b010;
    localparam FLT    = 3'b001;
    localparam FLE    = 3'b000;

    logic i_lui, i_auipc, i_jal, i_jalr, 
          i_beq, i_bne, i_blt, i_bge, 
          i_lw, i_lb, 
          i_sw, i_sb, i_swi, 
          i_addi, i_slli, i_slti, i_xori, i_ori, i_andi, i_srli, i_srai,
          i_add, i_sub, i_sll, i_srl, i_sra, i_slt, i_xor, i_or, i_and,
          i_mul, i_div,
          i_fload, i_fstore, 
          i_fadd, i_fsub, i_fmul, i_fdiv, i_fsqrt, 
          i_fsgnj, i_fsgnjn, i_fsgnjx, 
          i_feq, i_fle, i_flt, 
          i_fcvtws, i_fcvtsw;

    assign i_lui = (opcode == LUI);
    assign i_auipc = (opcode == AUIPC);
    assign i_jal = (opcode == JAL);
    assign i_jalr = (opcode == JALR);

    assign i_beq = (opcode == BRANCH && funct3 == BEQ);
    assign i_bne = (opcode == BRANCH && funct3 == BNE);
    assign i_blt = (opcode == BRANCH && funct3 == BLT);
    assign i_bge = (opcode == BRANCH && funct3 == BGE);

    assign i_lw = (opcode == LOAD && funct3 == LW);
    assign i_lb = (opcode == LOAD && funct3 == LB);

    assign i_sw = (opcode == STORE && funct3 == SW);
    assign i_sb = (opcode == STORE && funct3 == SB);
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

    assign i_mul = (opcode == CALC && funct3 == ADDSUBMUL && funct7 == MUL);
    assign i_div = (opcode == CALC && funct3 == XORDIV && funct7 == DIV);

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

    // memtoreg
    // 2'b00 -> result (alu or fpu)
    // 2'b01 -> memrdata
    // 2'b10 -> pc + 4
    // 2'b11 -> pc + (signed)imm
    assign memtoreg = (i_lw | i_lb | i_fload) ? 2'b01 :
                      (i_jal | i_jalr) ? 2'b10 :
                      (i_auipc) ? 2'b11 :
                      2'b00;

    // memwrite
    // 1'b0 -> don't write
    // 1'b1 -> write
    assign memwrite = (i_sw | i_sb | i_fstore);

    // memread
    // 1'b0 -> don't read
    // 1'b1 -> read
    assign memread = (i_lw | i_lb | i_fload);

    // imemwrite
    // 1'b0 -> don't write
    // 1'b1 -> write
    assign imemwrite = i_swi;

    // branchjump
    // 2'b00 -> pc += 4
    // 2'b01 -> branch
    // 2'b10 -> pc += (signed)imm (JAL)
    // 2'b11 -> pc = aluresult (JALR)
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
    // 4'b1100 -> *
    // 4'b1101 -> /
    // default -> 
    assign aluop = i_sub ? 4'b0001:
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
                   i_mul ? 4'b1100:
                   i_div ? 4'b1101:
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
    // default -> 
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
                   4'b0000;

    // alusrc0
    // 1'b0 -> rdata0(from integer register file)
    // 1'b1 -> 0 (LUI)
    assign alusrc0 = i_lui;

    // alusrc1
    // 1'b0 -> rdata1(from integer register file)
    // 1'b1 -> imm
    assign alusrc1 = (i_lui || i_jalr || i_lw || i_lb || i_sw || i_sb || i_swi ||
                      opcode == CALCI || i_fload || i_fstore);

    // fpusrc0
    // 1'b0 -> frdata0(from floating point register file)
    // 1'b1 -> rdata0(from integer register file) fcvtsw
    assign fpusrc0 = i_fcvtsw;

    // regwrite
    // 1'b0 -> don't write
    // 1'b1 -> write
    assign regwrite = ~(opcode == BRANCH || i_sw || i_sb || i_swi || i_fstore ||
                        (opcode == F && ~i_fcvtws));

    // fregwrite
    // 1'b0 -> don't write
    // 1'b1 -> write
    assign fregwrite = (i_fload || (opcode == F && ~i_fcvtws));

    // aluorfpu
    // 1'b0 -> aluresult & memwdata = read1
    // 1'b1 -> fpuresult & memwdata = fread1
    assign aluorfpu = opcode == F || i_fload || i_fstore;

    // wordorbyte
    // 1'b0 -> word
    // 1'b1 -> byte
    assign wordorbyte = i_lb || i_sb;

endmodule