`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/11 22:18:24
// Design Name: 
// Module Name: immgen_tb
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


module immgen_tb();
    logic clk;
    logic [31:0] instr;
    logic [31:0] imm;

    immgen immgen(.instr(instr),
                  .imm(imm));

    parameter CYCLE = 10;
    always #(CYCLE/2) begin
        clk = ~clk;
    end

    initial begin
        clk = 0;

        @(posedge clk);
        instr = 32'b000100010001_00000_000_00000_0010011; // addi x0, x0, 273 -> imm = 273(00000111)

        @(posedge clk);
        instr = 32'b0001000_00000_00000_000_10000_0100011; // sb 272(x0), x0 -> imm = 272(00000110)

        @(posedge clk);
        instr = 32'b1_111111_00000_00000_000_1100_1_1100011; // beq x0, x0, -8 -> imm = -8(fffffff8)

        @(posedge clk);
        instr = 32'b11111111111111111010_00000_0110111; // lui x0, -6 -> imm = -6(ffffa000)  

        @(posedge clk);
        instr = 32'b0_0000000001_0_00000000_00000_1101111; // jal x0, 2 -> imm = 2(00000002)

        @(posedge clk);
        $finish();
    end

endmodule
