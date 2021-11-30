

module hazard_unit
   (
    input logic [5:0] rs0D,
    input logic [5:0] rs1D,
    input logic [5:0] rdE,
    input logic [5:0] rdM,
    input logic regwriteE,
    input logic memreadE,
    input logic regwriteM,

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