`default_nettype none
`timescale 1ns / 1ps

module hazard_unit
   (
    input wire [5:0] rs0D,
    input wire [5:0] rs1D,
    input wire [5:0] rdE,
    input wire [5:0] rdM,
    input wire regwriteE,
    input wire memreadE,
    input wire regwriteM,

    output logic [1:0] forward0,
    output logic [1:0] forward1,
    output logic lwstall
   );

    assign forward0 = (rs0D != 0 && rdE == rs0D && regwriteE) ? 2'b01:
                      (rs0D != 0 && rdM == rs0D && regwriteM) ? 2'b10:
                      2'b00;
    
    assign forward1 = (rs1D != 0 && rdE == rs1D && regwriteE) ? 2'b01:
                      (rs1D != 0 && rdM == rs1D && regwriteM) ? 2'b10:
                      2'b00;

    assign lwstall = (rs0D == rdE || rs1D == rdE) && memreadE;
endmodule
`default_nettype wire
