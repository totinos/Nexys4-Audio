`timescale 1ns / 1ps

/**********************************************************/
/*  A module to implement dual port synchronous BRAM      */
/**********************************************************/
module SRAM #(parameter ADDR_WIDTH=8, DATA_WIDTH=8, DEPTH=256) (
    input logic clk,
    input logic write_enable,
    input logic [ADDR_WIDTH-1:0] read_addr,
    input logic [ADDR_WIDTH-1:0] write_addr,
    input logic [DATA_WIDTH-1:0] input_data,
    output logic [DATA_WIDTH-1:0] output_data
    // INCLUDE WRITE ENABLE AND/OR READ_ENABLE?????????????????????????????????????????????????
    );
    
    logic [DATA_WIDTH-1:0] memory [0:DEPTH-1];
    
    always_ff @(posedge clk) begin
        memory[write_addr] <= input_data;
        output_data <= memory[read_addr];
    end
endmodule
