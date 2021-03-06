`timescale 1ns / 1ps

/**********************************************************/
/*  A module to implement a simple logic clock divider.   */
/**********************************************************/
module clk_div #(parameter NUM_DIVISIONS=8) (
    input logic clk_in,
    input logic reset,
    output logic clk_out
    );
    
    logic [NUM_DIVISIONS-1:0] count;
    
    always_ff @(posedge clk_in) begin
        
        if (reset) begin
            count <= 0;
            clk_out <= 0;
        end
        
        else begin
            if (count == 0) clk_out <= ~clk_out;
            count <= count + 1;
        end
    end
endmodule
