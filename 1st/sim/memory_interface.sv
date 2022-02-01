`default_nettype none
`timescale 1ns / 1ps

// temporary memory 
// always cache miss
// stall 0 ~ 16 clock virtually
module memory_interface
   (input wire clk,
    input wire rstn,
    input wire [31:0] addr,
    input wire [31:0] data_in,
    input wire write_enable,
    input wire read_enable,
    output logic [31:0] data_out,
    output logic miss
   );

    // ram_block_data dmem(.clk(clk),
    //                     .we(write_enable),
    //                     .addr(addr[17:2]),
    //                     .di(data_in),
    //                     .dout(data_out));
    // assign miss = 1'b0;
    
    // logic [31:0] temp_data;
    // ram_block_data dmem(.clk(clk),
    //                     .we(write_enable),
    //                     .addr(addr[17:2]),
    //                     .di(data_in),
    //                     .dout(temp_data));

    // logic [3:0] cnt;
    // logic before_read_enable;
    // always_ff @(posedge clk) begin
    //     if (~rstn) begin
    //         cnt <= 4'b0;
    //         miss <= 1'b0;
    //         before_read_enable <= 1'b0;
    //     end else begin
    //         if (read_enable) begin
    //             miss <= 1'b1;
    //             before_read_enable <= 1'b1;
    //         end else if (before_read_enable) begin
    //             data_out <= temp_data;
    //             before_read_enable <= 1'b0;
    //         end else if (cnt == 4'b00) begin
    //             miss <= 1'b0;
    //         end
    //         cnt <= cnt + 4'b1;
    //     end
    // end

    logic [31:0] temp_data;
    ram_block_data dmem(.clk(clk),
                        .we(write_enable),
                        .addr(addr[17:2]),
                        .di(data_in),
                        .dout(data_out));

    logic [3:0] cnt;
    logic before_read_enable;
    always_ff @(posedge clk) begin
        if (~rstn) begin
            cnt <= 4'b0;
            miss <= 1'b0;
            before_read_enable <= 1'b0;
        end else begin
            if (write_enable) begin
                miss <= 1'b1;
                before_read_enable <= 1'b1;
            end else if (before_read_enable) begin
                //data_out <= temp_data;
                before_read_enable <= 1'b0;
            end else if (cnt == 4'b00) begin
                miss <= 1'b0;
            end
            cnt <= cnt + 4'b1;
        end
    end

endmodule
`default_nettype wire
