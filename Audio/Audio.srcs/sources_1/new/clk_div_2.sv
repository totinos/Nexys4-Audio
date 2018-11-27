`timescale 1ns / 1ps

/**********************************************************/
/*  A module to implement a simple logic clock divider.   */
/**********************************************************/
module clk_div_2 (
    input logic clk_in,
    input logic reset,
    input logic [3:0] select,
    output logic clk_out
    );
    
    // Internal clock signals
    logic clk_50MHz;
    logic clk_25MHz;
    logic clk_13MHz;
    logic clk_6MHz;
    logic clk_3MHz;
    logic clk_2MHz;
    logic clk_781kHz;
    logic clk_391kHz;
    logic clk_195kHz;
    logic clk_98kHz;
    logic clk_49kHz;
    logic clk_24kHz;
    logic clk_12kHz;
    logic clk_6kHz;
    logic clk_3kHz;
    logic clk_divided;
    
    // Count signal and divided clock signal
    logic [15:0] count;
    logic [15:0] divider;
    
    // Multiplex the clock signals
    always_comb begin
        case (select)
            4'b0001: clk_divided = clk_50MHz;
            4'b0010: clk_divided = clk_25MHz;
            4'b0011: clk_divided = clk_13MHz;
            4'b0100: clk_divided = clk_6MHz;
            4'b0101: clk_divided = clk_3MHz;
            4'b0110: clk_divided = clk_2MHz;
            4'b0111: clk_divided = clk_781kHz;
            4'b1000: clk_divided = clk_391kHz;
            4'b1001: clk_divided = clk_195kHz;
            4'b1010: clk_divided = clk_98kHz;
            4'b1011: clk_divided = clk_49kHz;
            4'b1100: clk_divided = clk_24kHz;
            4'b1101: clk_divided = clk_12kHz;
            4'b1110: clk_divided = clk_6kHz;
            4'b1111: clk_divided = clk_3kHz;
            default: clk_divided = clk_in;
        endcase
    end
    
    // Divide the clock using a counter
    always_ff @(posedge clk_in) begin
        
        if (reset) begin
            count <= 0;
            clk_out <= 0;
        end else begin
            if (count >= divider) begin
                count <= 0;
                clk_out <= ~clk_out;
            end else begin
                count <= count + 1;
            end
        end
    end
endmodule