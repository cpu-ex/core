
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/02/01 11:30:00
// Design Name: 
// Module Name: branch
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

module branch_unit(
    input wire [31:0] src0,
    input wire [31:0] src1,
    input wire [1:0] branchop, 
    output logic flag
    );

    always_comb begin
        unique case (branchop)
            2'b00: flag = src0 == src1 ? 1'b1 : 1'b0; // BEQ
            2'b01: flag = src0 == src1 ? 1'b0 : 1'b1;  // BNE
            2'b10: flag = $signed(src0) <  $signed (src1) ? 1'b1 : 1'b0; // BLT
            2'b11: flag = $signed(src0) >= $signed (src1) ? 1'b1 : 1'b0; // BGE
            default: flag = 1'b0;
        endcase
    end

endmodule

module bimodal_predictor
  #(parameter INDEX_WIDTH = 8) // pht size = 2 ^ INDEX_WIDTH
   (input wire clk,
    input wire rstn,
    // predict
    input wire [31:0] pc_predict,
    output wire prediction,
    // update
    input wire [31:0] pc_update,
    input wire update,
    input wire taken);
    // assume update is not set to 1 continuously
    //        do not exec branch instruction continuously

    // predict
    wire [INDEX_WIDTH-1:0] index_predict = pc_predict[INDEX_WIDTH+1:2];
    logic [1:0] predict_data;
    assign prediction = (predict_data >= 2'd2);

    // update
    wire  [INDEX_WIDTH-1:0] index_update = pc_update[INDEX_WIDTH+1:2];
    logic [INDEX_WIDTH-1:0] before_index_update;
    logic [INDEX_WIDTH-1:0] index_update_mem;
    logic [1:0] old_update_data, new_update_data;
    logic state, before_taken;
    assign index_update_mem = state ? before_index_update : index_update;
    assign new_update_data = before_taken ? ((old_update_data < 2'd3) ? old_update_data + 2'd1 : old_update_data):
                                            ((old_update_data > 2'd0) ? old_update_data - 2'd1 : old_update_data);

    always_ff @(posedge clk) begin
        if (~rstn) begin
            before_index_update <= '0;
            state <= 1'b0;
            before_taken <= 1'b0;
        end else begin
            if (update) begin 
                state <= 1'b1;
            end else begin
                state <= 1'b0;
            end
            before_taken <= taken;
            before_index_update <= index_update;
        end
    end


    ram_block_2p #(.ADDR_WIDTH(INDEX_WIDTH),
                   .DATA_WIDTH(2)) 
    pht(.clk(clk),
        .addr0(index_predict),
        .enable0(1'b1),
        .write_enable0(1'b0),
        .read_data0(predict_data),
        .write_data0(2'b00),
        .addr1(index_update_mem),
        .enable1(1'b1),
        .write_enable1(state),
        .read_data1(old_update_data),
        .write_data1(new_update_data));

endmodule

`default_nettype wire
