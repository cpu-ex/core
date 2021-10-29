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
    output logic imemwrite,
    output logic [1:0] branchjump, 
    output logic [3:0] aluop,
    output logic [3:0] fpuop,
    output logic alusrc0,
    output logic alusrc1,
    output logic fpusrc0,
    output logic regwrite,
    output logic fregwrite,
    output logic [1:0] tomem, 
    output logic aluorfpu,
    output logic uart_wr_en,
    output logic uart_rd_en,
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
    localparam STORE  = 7'b0100011; // sw, sb
    localparam CALCI  = 7'b0010011; // addi, slti, slli, srli, srai, xori, andi, ori
    localparam CALC   = 7'b0110011; // add, sub, slt, sll, srl, sra, xor, and, or, mul, div
    localparam FLOAD  = 7'b0000111; // fl
    localparam FSTORE = 7'b0100111; // fs
    localparam F      = 7'b1010011; // fadd, fsub, fmul, fdiv, fsqrt, fsgnj, fsgnjn, fsgnjx, feq, fle, flt, fcvt.s.w, fcvt.w.s  
    localparam IO     = 7'b0000000; // in-i, in-d, out
    

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


    logic [24:0] controls;
    assign { memtoreg
            ,memwrite
            ,imemwrite
            ,branchjump
            ,aluop
            ,fpuop
            ,alusrc0
            ,alusrc1
            ,fpusrc0
            ,regwrite
            ,fregwrite
            ,tomem
            ,aluorfpu
            ,uart_wr_en
            ,uart_rd_en
            ,wordorbyte} = controls;
    
    // memtoreg
    // 2'b00 -> result (alu or fpu)
    // 2'b01 -> memrdata
    // 2'b10 -> pc + 4
    // 2'b11 -> pc + (signed)imm

    // memwrite
    // 1'b0 -> don't write
    // 1'b1 -> write

    // imemwrite
    // 1'b0 -> don't write
    // 1'b1 -> write

    // branchjump
    // 2'b00 -> pc += 4
    // 2'b01 -> branch
    // 2'b10 -> pc += (signed)imm (JAL)
    // 2'b11 -> pc = aluresult (JALR)

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

    // alusrc0
    // 1'b0 -> rdata0(from integer register file)
    // 1'b1 -> 0 (LUI)

    // alusrc1
    // 1'b0 -> rdata1(from integer register file)
    // 1'b1 -> imm

    // fpusrc0
    // 1'b0 -> frdata0(from floating point register file)
    // 1'b1 -> rdata0(from integer register file) fcvtsw

    // regwrite
    // 1'b0 -> don't write
    // 1'b1 -> write

    // fregwrite
    // 1'b0 -> don't write
    // 1'b1 -> write

    // tomem
    // 2'b00 -> rdata1(from integer register file)
    // 2'b01 -> frdata1(from floating point register file)
    // 2'b10 -> indata = {24'b0, uart_rx_data}
    // 2'b11 ->

    // aluorfpu
    // 1'b0 -> aluresult
    // 1'b1 -> fpuresult

    // uart_wr_en
    // 1'b0 -> don't write
    // 1'b1 -> write

    // uart_rd_en
    // 1'b0 -> don't read
    // 1'b1 -> read

    // wordorbyte
    // 1'b0 -> word
    // 1'b1 -> byte

    // anything ok -> 0

    always_comb begin
        case (opcode) 
            LUI    : controls = 25'b00_0_0_00_0000_0000_1_1_0_1_0_00_0_0_0_0;
            AUIPC  : controls = 25'b11_0_0_00_0000_0000_0_0_0_1_0_00_0_0_0_0;
            JAL    : controls = 25'b10_0_0_10_0000_0000_0_0_0_1_0_00_0_0_0_0;
            JALR   : controls = 25'b10_0_0_11_0000_0000_0_1_0_1_0_00_0_0_0_0;
            BRANCH : controls = funct3 == BEQ ? 25'b00_0_0_01_0001_0000_0_0_0_0_0_00_0_0_0_0:
                                funct3 == BNE ? 25'b00_0_0_01_1001_0000_0_0_0_0_0_00_0_0_0_0:   
                                funct3 == BLT ? 25'b00_0_0_01_1010_0000_0_0_0_0_0_00_0_0_0_0:   
                                funct3 == BGE ? 25'b00_0_0_01_1011_0000_0_0_0_0_0_00_0_0_0_0:
                                25'b0;
            LOAD   : controls = funct3 == LW ? 25'b01_0_0_00_0000_0000_0_1_0_1_0_00_0_0_0_0:
                                funct3 == LB ? 25'b01_0_0_00_0000_0000_0_1_0_1_0_00_0_0_0_1:
                                25'b0;
            STORE  : controls = funct3 == SW ? 25'b00_1_0_00_0000_0000_0_1_0_0_0_00_0_0_0_0:
                                funct3 == SB ? 25'b00_1_0_00_0000_0000_0_1_0_0_0_00_0_0_0_1:
                                25'b0;
            CALCI  : controls = funct3 == ADDSUBMUL ? 25'b00_0_0_00_0000_0000_0_1_0_1_0_00_0_0_0_0: // addi (subi, muli don't exist)
                                funct3 == SLL       ? 25'b00_0_0_00_0110_0000_0_1_0_1_0_00_0_0_0_0:
                                funct3 == SLT       ? 25'b00_0_0_00_0010_0000_0_1_0_1_0_00_0_0_0_0: 
                                funct3 == XORDIV    ? 25'b00_0_0_00_0011_0000_0_1_0_1_0_00_0_0_0_0: // xori (div1 don't exist)
                                funct3 == OR        ? 25'b00_0_0_00_0101_0000_0_1_0_1_0_00_0_0_0_0: 
                                funct3 == AND       ? 25'b00_0_0_00_0100_0000_0_1_0_1_0_00_0_0_0_0: 
                                funct7 == SRL       ? 25'b00_0_0_00_0111_0000_0_1_0_1_0_00_0_0_0_0: 
                                funct7 == SRA       ? 25'b00_0_0_00_1000_0000_0_1_0_1_0_00_0_0_0_0: 
                                25'b0;
            CALC   :case (funct3) 
                        ADDSUBMUL : controls = funct7 == ADD ? 25'b00_0_0_00_0000_0000_0_0_0_1_0_00_0_0_0_0:
                                               funct7 == SUB ? 25'b00_0_0_00_0001_0000_0_0_0_1_0_00_0_0_0_0:
                                               funct7 == MUL ? 25'b00_0_0_00_1100_0000_0_0_0_1_0_00_0_0_0_0:
                                               25'b0;
                        SLL       : controls = 25'b00_0_0_00_0110_0000_0_0_0_1_0_00_0_0_0_0;
                        SR        : controls = funct7 == SRL ? 25'b00_0_0_00_0111_0000_0_0_0_1_0_00_0_0_0_0:
                                               funct7 == SRA ? 25'b00_0_0_00_1000_0000_0_0_0_1_0_00_0_0_0_0:
                                               25'b0;
                        SLT       : controls = 25'b00_0_0_00_0010_0000_0_0_0_1_0_00_0_0_0_0;
                        XORDIV    : controls = funct7 == XOR ? 25'b00_0_0_00_0011_0000_0_0_0_1_0_00_0_0_0_0:
                                               funct7 == DIV ? 25'b00_0_0_00_1101_0000_0_0_0_1_0_00_0_0_0_0:
                                               25'b0;
                        OR        : controls = 25'b00_0_0_00_0101_0000_0_0_0_1_0_00_0_0_0_0;
                        AND       : controls = 25'b00_0_0_00_0100_0000_0_0_0_1_0_00_0_0_0_0;
                    endcase
            FLOAD  : controls = 25'b01_0_0_00_0000_0000_0_1_0_0_1_00_0_0_0_0;
            FSTORE : controls = 25'b00_1_0_00_0000_0000_0_1_0_0_0_01_0_0_0_0;
            F      :case (funct7)
                        FADD   : controls = 25'b00_0_0_00_0000_0000_0_0_0_0_1_00_1_0_0_0;
                        FSUB   : controls = 25'b00_0_0_00_0000_0001_0_0_0_0_1_00_1_0_0_0;
                        FMUL   : controls = 25'b00_0_0_00_0000_0010_0_0_0_0_1_00_1_0_0_0;
                        FDIV   : controls = 25'b00_0_0_00_0000_0011_0_0_0_0_1_00_1_0_0_0;
                        FSQRT  : controls = 25'b00_0_0_00_0000_0100_0_0_0_0_1_00_1_0_0_0;
                        FSGN   : controls = funct3 == FSGNJ  ? 25'b00_0_0_00_0000_0101_0_0_0_0_1_00_1_0_0_0:
                                            funct3 == FSGNJN ? 25'b00_0_0_00_0000_0110_0_0_0_0_1_00_1_0_0_0:
                                            funct3 == FSGNJX ? 25'b00_0_0_00_0000_0111_0_0_0_0_1_00_1_0_0_0:
                                            25'b0;
                        FCMP   : controls = funct3 == FEQ ? 25'b00_0_0_00_0000_1000_0_0_0_0_1_00_1_0_0_0: 
                                            funct3 == FLE ? 25'b00_0_0_00_0000_1001_0_0_0_0_1_00_1_0_0_0: 
                                            funct3 == FLT ? 25'b00_0_0_00_0000_1010_0_0_0_0_1_00_1_0_0_0: 
                                            25'b0;
                        FCVTWS : controls = 25'b00_0_0_00_0000_1011_0_0_0_1_0_00_1_0_0_0;
                        FCVTSW : controls = 25'b00_0_0_00_0000_1100_0_0_1_0_1_00_1_0_0_0;        
                    endcase
            IO     : controls = funct3 == OUT ? 25'b01_0_0_00_0000_0000_0_1_0_0_0_00_0_1_0_1:
                                funct3 == IND ? 25'b00_1_0_00_0000_0000_0_1_0_0_0_10_0_0_1_1:
                                funct3 == INI ? 25'b00_0_1_00_0000_0000_0_1_0_0_0_00_0_0_1_1:
                                25'b0;  
            default: controls = 25'b0;   
        endcase
    end

endmodule