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
    output logic [1:0] branchjump, 
    output logic [1:0] aluop,
    output logic alusrc0,
    output logic alusrc1,
    output logic regwrite
    //...
    );

    // opcode
    parameter LUI    = 7'b0110111;
    parameter AUIPC  = 7'b0010111;
    parameter JAL    = 7'b1101111;
    parameter JALR   = 7'b1100111;
    parameter BRANCH = 7'b1100011;
    parameter LOAD   = 7'b0000011;
    parameter STORE  = 7'b0100011;
    parameter CALCI  = 7'b0010011;
    parameter CALC   = 7'b0110011;
    parameter IO     = 7'b0000000;

    // funct3
    parameter ADDSUB = 3'b000;
    parameter SLT = 3'b010;

    // funct7 
    parameter ADD = 7'b0000000;
    parameter SUB = 7'b0100000;

    logic [9:0] controls;
    assign { memtoreg
            ,memwrite
            ,branchjump
            ,aluop
            ,alusrc0
            ,alusrc1
            ,regwrite} = controls;
    
    // memtoreg
    // 2'b00 -> aluresult
    // 2'b01 -> mem[]
    // 2'b10 -> pc + 4
    // 2'b11 -> pc + (signed)imm

    // memwrite
    // 1'b0 -> don't write
    // 1'b1 -> write

    // branchjump
    // 2'b00 -> pc += 4
    // 2'b01 -> branch
    // 2'b10 -> pc += (signed)imm (JAL)
    // 2'b11 -> pc = aluresult (JALR)

    // aluop
    // 2'b00 -> +
    // 2'b01 -> -
    // 2'b10 -> slt
    // 2'b11 -> 

    // alusrc0
    // 1'b0 -> rdata0(from register file)
    // 1'b1 -> 0 (LUI)

    // alusrc1
    // 1'b0 -> rdata1(from register file)
    // 1'b1 -> imm

    // regwrite
    // 1'b0 -> don't write
    // 1'b1 -> write

    // anything ok -> 0

    always_comb begin
        case (opcode) 
            LUI    : controls = 10'b00_0_00_00_1_1_1;
            AUIPC  : controls = 10'b11_0_00_00_0_0_1;
            JAL    : controls = 10'b10_0_10_00_0_0_1;
            JALR   : controls = 10'b10_0_11_00_0_1_1;
            BRANCH : controls = 10'b00_0_01_01_0_0_0;
            LOAD   : controls = 10'b01_0_00_00_0_1_1;
            STORE  : controls = 10'b00_1_00_00_0_1_0;
            CALCI  : controls = funct3 == ADDSUB ? 10'b00_0_00_00_0_1_1:
                                funct3 == SLT ? 10'b00_0_00_10_0_1_1:
                                10'b0;
            CALC   : controls = funct3 == SLT ? 10'b00_0_00_10_0_0_1:
                                funct7 == ADD ? 10'b00_0_00_00_0_0_1:
                                funct7 == SUB ? 10'b00_0_00_01_0_0_1:
                                10'b0;
            IO     : controls = 10'b01_0_00_00_0_1_0;
            default: controls = 10'b0;
        endcase
    end

endmodule
