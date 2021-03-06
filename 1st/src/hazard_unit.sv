`default_nettype none
`timescale 1ns / 1ps

module hazard_unit
   (
    input wire [5:0] rs0D,
    input wire [5:0] rs1D,
    input wire [5:0] rs2D,
    input wire [5:0] rs3D,
    input wire [5:0] rs4D,
    input wire [5:0] rs5D,
    input wire [5:0] rdE,
    input wire [5:0] rdE2,
    input wire [5:0] rdE3,
    input wire [5:0] rdE4,
    input wire [5:0] rdE5,
    input wire [5:0] rdM,
    input wire [5:0] rdM2,
    input wire [5:0] rdM3,
    input wire [5:0] rdM4,
    input wire [5:0] rdM5,
    input wire i_vswD,
    input wire regwriteE,
    input wire vec_regwriteE,
    input wire memreadE,
    input wire regwriteM,
    input wire vec_regwriteM,

    output logic [2:0] forward0,
    output logic [2:0] forward1,
    output logic [2:0] forward2,
    output logic [2:0] forward3,
    output logic [2:0] forward4,
    output logic [2:0] forward5,
    output logic lwstall
   );

    // expect mask[i] == 0 -> reg_i == x0
    wire rs0D_neqz = (rs0D != 0);
    wire rs1D_neqz = (rs1D != 0);
    wire rs2D_neqz = (rs2D != 0);
    wire rs3D_neqz = (rs3D != 0);
    wire rs4D_neqz = (rs4D != 0);
    wire rs5D_neqz = (rs5D != 0);

    assign forward0 = (rs0D_neqz && rdE  == rs0D && regwriteE)     ? 3'b001:
                      (rs0D_neqz && rdM  == rs0D && regwriteM)     ? 3'b010:
                      (rs0D_neqz && rdM2 == rs0D && vec_regwriteM) ? 3'b011: 
                      (rs0D_neqz && rdM3 == rs0D && vec_regwriteM) ? 3'b100:
                      (rs0D_neqz && rdM4 == rs0D && vec_regwriteM) ? 3'b101:
                      (rs0D_neqz && rdM5 == rs0D && vec_regwriteM) ? 3'b110:
                      3'b000;
    
    assign forward1 = (rs1D_neqz && rdE  == rs1D && regwriteE)     ? 3'b001:
                      (rs1D_neqz && rdM  == rs1D && regwriteM)     ? 3'b010:
                      (rs1D_neqz && rdM2 == rs1D && vec_regwriteM) ? 3'b011: 
                      (rs1D_neqz && rdM3 == rs1D && vec_regwriteM) ? 3'b100:
                      (rs1D_neqz && rdM4 == rs1D && vec_regwriteM) ? 3'b101:
                      (rs1D_neqz && rdM5 == rs1D && vec_regwriteM) ? 3'b110:
                      3'b000;

    assign forward2 = (rs2D_neqz && rdE  == rs2D && regwriteE)     ? 3'b001:
                      (rs2D_neqz && rdM  == rs2D && regwriteM)     ? 3'b010:
                      (rs2D_neqz && rdM2 == rs2D && vec_regwriteM) ? 3'b011: 
                      (rs2D_neqz && rdM3 == rs2D && vec_regwriteM) ? 3'b100:
                      (rs2D_neqz && rdM4 == rs2D && vec_regwriteM) ? 3'b101:
                      (rs2D_neqz && rdM5 == rs2D && vec_regwriteM) ? 3'b110:
                      3'b000;
    
    assign forward3 = (rs3D_neqz && rdE  == rs3D && regwriteE)     ? 3'b001:
                      (rs3D_neqz && rdM  == rs3D && regwriteM)     ? 3'b010:
                      (rs3D_neqz && rdM2 == rs3D && vec_regwriteM) ? 3'b011: 
                      (rs3D_neqz && rdM3 == rs3D && vec_regwriteM) ? 3'b100:
                      (rs3D_neqz && rdM4 == rs3D && vec_regwriteM) ? 3'b101:
                      (rs3D_neqz && rdM5 == rs3D && vec_regwriteM) ? 3'b110:
                      3'b000;

    assign forward4 = (rs4D_neqz && rdE  == rs4D && regwriteE)     ? 3'b001:
                      (rs4D_neqz && rdM  == rs4D && regwriteM)     ? 3'b010:
                      (rs4D_neqz && rdM2 == rs4D && vec_regwriteM) ? 3'b011: 
                      (rs4D_neqz && rdM3 == rs4D && vec_regwriteM) ? 3'b100:
                      (rs4D_neqz && rdM4 == rs4D && vec_regwriteM) ? 3'b101:
                      (rs4D_neqz && rdM5 == rs4D && vec_regwriteM) ? 3'b110:
                      3'b000;

    assign forward5 = (rs5D_neqz && rdE  == rs5D && regwriteE)     ? 3'b001:
                      (rs5D_neqz && rdM  == rs5D && regwriteM)     ? 3'b010:
                      (rs5D_neqz && rdM2 == rs5D && vec_regwriteM) ? 3'b011: 
                      (rs5D_neqz && rdM3 == rs5D && vec_regwriteM) ? 3'b100:
                      (rs5D_neqz && rdM4 == rs5D && vec_regwriteM) ? 3'b101:
                      (rs5D_neqz && rdM5 == rs5D && vec_regwriteM) ? 3'b110:
                      3'b000;
    
    // lwstall
    // expect mask[i] == 0 -> reg_i == x0
    wire SS_depend = (rs0D_neqz && rs0D == rdE) || 
                     (rs1D_neqz && rs1D == rdE);
    wire SV_depend = (rs2D_neqz && rs2D == rdE) || 
                     (rs3D_neqz && rs3D == rdE) || 
                     (rs4D_neqz && rs4D == rdE) || 
                     (rs5D_neqz && rs5D == rdE);
    wire VS_depend = (rs0D_neqz && (rs0D == rdE2 || rs0D == rdE3 || rs0D == rdE4 || rs0D == rdE5)) || 
                     (rs1D_neqz && (rs1D == rdE2 || rs1D == rdE3 || rs1D == rdE4 || rs1D == rdE5));
    wire VV_depend = (rs2D_neqz && (rs2D == rdE2 || rs2D == rdE3 || rs2D == rdE4 || rs2D == rdE5)) || 
                     (rs3D_neqz && (rs3D == rdE2 || rs3D == rdE3 || rs3D == rdE4 || rs3D == rdE5)) ||
                     (rs4D_neqz && (rs4D == rdE2 || rs4D == rdE3 || rs4D == rdE4 || rs4D == rdE5)) ||
                     (rs5D_neqz && (rs5D == rdE2 || rs5D == rdE3 || rs5D == rdE4 || rs5D == rdE5)) ;
    assign lwstall = (SS_depend && memreadE               ) ||
                     (SV_depend && memreadE      && i_vswD) ||
                     (VS_depend && vec_regwriteE          ) ||
                     (VV_depend && vec_regwriteE && i_vswD);

endmodule
`default_nettype wire
