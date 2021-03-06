`ifndef __inst__
`define __inst__

typedef struct packed {
    logic [31:0] pc;
    logic [31:0] imm;

    logic [5:0] rs0;
    logic [5:0] rs1;
    logic [5:0] rd;

    logic memtoreg;
    logic memwrite;
    logic memread;
    logic imemwrite;
    logic [1:0] branchjump;
    logic [3:0] aluop;
    logic [3:0] fpuop;
    logic [2:0] branchop;
    logic [1:0] src0;
    logic [1:0] src1;
    logic regwrite;
    logic aluorfpu;
    logic prediction;
    logic [7:0] pc_xor_global_history;

    // vec lw, sw
    logic [5:0] reg2;
    logic [5:0] reg3;
    logic [5:0] reg4;
    logic [5:0] reg5;
    logic [3:0] vecmask;
    logic vecmode; 
    logic vec_regwrite;
} Inst;

`endif