`timescale 1ns / 1ps

/**********************************************************/
/*  A module to implement a manager for different clock   */
/*  dividers. Switches can be used to switch between the  */
/*  different clock speeds.                               */
/**********************************************************/
module clk_manager (
    input logic clk_100MHz,
    input logic reset,
    input logic [3:0] switches,
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
    
    // Instantiate components to divide the clock to different frequencies
    clk_div #(.NUM_DIVISIONS(1)) cdiv_50MHz (
        .clk_in(clk_100MHz),
        .reset(reset),
        .clk_out(clk_50MHz)
    ); 
    clk_div #(.NUM_DIVISIONS(2)) cdiv_25MHz (
        .clk_in(clk_100MHz),
        .reset(reset),
        .clk_out(clk_25MHz)
    );
    clk_div #(.NUM_DIVISIONS(3)) cdiv_13MHz (
        .clk_in(clk_100MHz),
        .reset(reset),
        .clk_out(clk_13MHz)
    );
    clk_div #(.NUM_DIVISIONS(4)) cdiv_6MHz (
        .clk_in(clk_100MHz),
        .reset(reset),
        .clk_out(clk_6MHz)
    );
    clk_div #(.NUM_DIVISIONS(5)) cdiv_3MHz (
        .clk_in(clk_100MHz),
        .reset(reset),
        .clk_out(clk_3MHz)
    );
    clk_div #(.NUM_DIVISIONS(6)) cdiv_2MHz (
        .clk_in(clk_100MHz),
        .reset(reset),
        .clk_out(clk_2MHz)
    );
    clk_div #(.NUM_DIVISIONS(7)) cdiv_781kHz (
        .clk_in(clk_100MHz),
        .reset(reset),
        .clk_out(clk_781kHz)
    );
    clk_div #(.NUM_DIVISIONS(8)) cdiv_391kHz (
        .clk_in(clk_100MHz),
        .reset(reset),
        .clk_out(clk_391kHz)
    );
    clk_div #(.NUM_DIVISIONS(9)) cdiv_195kHz (
        .clk_in(clk_100MHz),
        .reset(reset),
        .clk_out(clk_195kHz)
    );
    clk_div #(.NUM_DIVISIONS(10)) cdiv_98kHz (
        .clk_in(clk_100MHz),
        .reset(reset),
        .clk_out(clk_98kHz)
    );
    clk_div #(.NUM_DIVISIONS(11)) cdiv_49kHz (
        .clk_in(clk_100MHz),
        .reset(reset),
        .clk_out(clk_49kHz)
    );
    clk_div #(.NUM_DIVISIONS(12)) cdiv_24kHz (
        .clk_in(clk_100MHz),
        .reset(reset),
        .clk_out(clk_24kHz)
    );
    clk_div #(.NUM_DIVISIONS(13)) cdiv_12kHz (
        .clk_in(clk_100MHz),
        .reset(reset),
        .clk_out(clk_12kHz)
    );
    clk_div #(.NUM_DIVISIONS(14)) cdiv_6kHz (
        .clk_in(clk_100MHz),
        .reset(reset),
        .clk_out(clk_6kHz)
    );
    clk_div #(.NUM_DIVISIONS(15)) cdiv_3kHz (
        .clk_in(clk_100MHz),
        .reset(reset),
        .clk_out(clk_3kHz)
    );
    
    // Route a divided clock to the output based on the switch combination
    // The switches give the number of times to divide the 100MHz clock
    always_ff @(posedge clk_100MHz) begin
        case (switches)
            //4'b0000: clk_divided <= clk_100MHz;
            4'b0001: clk_divided <= clk_50MHz;
            4'b0010: clk_divided <= clk_25MHz;
            4'b0011: clk_divided <= clk_13MHz;
            4'b0100: clk_divided <= clk_6MHz;
            4'b0101: clk_divided <= clk_3MHz;
            4'b0110: clk_divided <= clk_2MHz;
            4'b0111: clk_divided <= clk_781kHz;
            4'b1000: clk_divided <= clk_391kHz;
            4'b1001: clk_divided <= clk_195kHz;
            4'b1010: clk_divided <= clk_98kHz;
            4'b1011: clk_divided <= clk_49kHz;
            4'b1100: clk_divided <= clk_24kHz;
            4'b1101: clk_divided <= clk_12kHz;
            4'b1110: clk_divided <= clk_6kHz;
            4'b1111: clk_divided <= clk_3kHz;
//            */
//            4'b00: clk_divided <= clk_781kHz;
//            4'b01: clk_divided <= clk_391kHz;
//            4'b10: clk_divided <= clk_195kHz;
//            4'b11: clk_divided <= clk_98kHz;
            default: clk_divided <= clk_50MHz;
        endcase
    end
    
    // Route the divided clock to the output of the clock divider module
    assign clk_out = clk_divided;
    
endmodule