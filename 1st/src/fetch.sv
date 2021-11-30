

module fetch
   (input wire clk,
    input wire rstn,
     /* verilator lint_off UNUSED */ input wire enable,
    output wire fin,

    output logic [31:0] imemraddr,
    input logic [31:0] imemrdata,
    input logic branchjump_miss,
    input logic lwstall,

    input logic [31:0] pc,
    input logic [31:0] pcnext,

    output logic [31:0] pc_out,
    output logic [31:0] instr);

    always_ff @(posedge clk) begin
        if (~rstn) begin
            pc_out <= 32'b0;
        end else begin
            pc_out <= imemraddr;
        end
    end

    assign imemraddr = lwstall ? pc_out :
                       branchjump_miss ? pcnext :
                       pc;
    assign instr = imemrdata;
    assign fin = 1'b1;

endmodule