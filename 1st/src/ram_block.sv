`default_nettype none
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/11 17:19:39
// Design Name: 
// Module Name: ram_block
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

module ram_block_data(
    input wire clk,
    input wire we,
    input wire [15:0] addr,
    input wire [31:0] di,
    output reg [31:0] dout 
    );

    (* ram_style = "block" *) reg [31:0] ram [((2 ** 16) - 1):0];

    always_ff @(posedge clk) begin
        if (we) begin
            ram[addr] <= di;
        end else begin
            dout <= ram[addr];
        end
    end

endmodule



// module ram_block_inst(
//     input wire clk,
//     input wire we,
//     input wire [14:0] raddr,
//     input wire [14:0] waddr,
//     input wire [31:0] di,
//     output reg [31:0] dout 
//     );

//     (* ram_style = "block" *) reg [31:0] ram [((2 ** 15) - 1):0];

//     initial begin
//         $readmemb("bootloader.mem",ram);
//     end

//     always_ff @(posedge clk) begin
//         if (we) begin
//             ram[waddr] <= di;
//         end
//         dout <= ram[raddr];
//     end

//     // assume raddr != waddr
//     // only bootloader have swi instruction  
// endmodule

module ram_block_inst
  #(parameter ADDR_WIDTH = 15,
    parameter DATA_WIDTH = 32)
   (input wire clk,
    input wire [ADDR_WIDTH-1:0] addr0,
    input wire enable0,
    input wire write_enable0,
    output logic [DATA_WIDTH-1:0] read_data0,
    input wire [DATA_WIDTH-1:0] write_data0,
    input wire [ADDR_WIDTH-1:0] addr1,
    input wire enable1,
    input wire write_enable1,
    output logic [DATA_WIDTH-1:0] read_data1,
    input wire [DATA_WIDTH-1:0] write_data1);

    (* ram_style = "block" *) reg [DATA_WIDTH-1:0] ram [(1 << ADDR_WIDTH) - 1:0];

    initial begin
        $readmemb("bootloader.mem",ram);
    end

    always_ff @(posedge clk) begin
        if (enable0) begin
            read_data0 <= ram[addr0];
            if (write_enable0) begin
                ram[addr0] <= write_data0;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (enable1) begin
            read_data1 <= ram[addr1];
            if (write_enable1) begin
                ram[addr1] <= write_data1;
            end
        end
    end

endmodule

module ram_block_2p
  #(parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 2)
   (input wire clk,
    input wire [ADDR_WIDTH-1:0] addr0,
    input wire enable0,
    input wire write_enable0,
    output logic [DATA_WIDTH-1:0] read_data0,
    input wire [DATA_WIDTH-1:0] write_data0,
    input wire [ADDR_WIDTH-1:0] addr1,
    input wire enable1,
    input wire write_enable1,
    output logic [DATA_WIDTH-1:0] read_data1,
    input wire [DATA_WIDTH-1:0] write_data1);

    (* ram_style = "block" *) reg [DATA_WIDTH-1:0] ram [(1 << ADDR_WIDTH) - 1:0];

    initial begin
        for (int i = 0;i < (1 << ADDR_WIDTH); i += 1) begin
            ram[i] <= '0;
        end
    end

    always_ff @(posedge clk) begin
        if (enable0) begin
            read_data0 <= ram[addr0];
            if (write_enable0) begin
                ram[addr0] <= write_data0;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (enable1) begin
            read_data1 <= ram[addr1];
            if (write_enable1) begin
                ram[addr1] <= write_data1;
            end
        end
    end

endmodule

`default_nettype wire
