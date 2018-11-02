`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2018 02:34:58 PM
// Design Name: 
// Module Name: top
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


module top #(parameter ADC_WIDTH=12) (
    input clk,
    input logic reset,
    input logic ready,
    
    //XADC guitar input
    input logic vauxp3,
    input logic vauxn3,

    output logic AUD_PWM,
    output logic AUD_SD
    );

    logic clk_25MHz;

    logic [ADC_WIDTH-1:0] aux_in;
    logic [ADC_WIDTH-1:0] aux_out;

    logic [ADC_WIDTH-1:0] chipTemp;
    logic [ADC_WIDTH-1:0] PWM;
    
    // Instantiate a clock divider
    clk_div #(.NUM_DIVISIONS(8)) cdiv (
        .clk_in(clk),
        .reset(reset),
        .clk_out(clk_25MHz)
    );

    // Instantiate an ADC to sample audio input
    AnalogXADC xadc (
        .aux_data(aux_in),  
        .temp_data(chipTemp),
        .vauxp3(vauxp3),
        .vauxn3(vauxn3),
        .CLK100MHZ(clk)
    );
    
    // Instantiate a module to delay the audio signal
    delay #(.DELAY(17)) top_delay (
        .clk(clk_25MHz),
        .reset(reset),
        .ready(ready),
        .audio_in(aux_in),
        .audio_out(aux_out)
    );
    
    // Connect delay module output to PWM 
    always_ff @(posedge clk) begin
        PWM <= aux_out;
    end
    
    // Enable the audio output port
    assign AUD_SD = 1'b1;
    
    /*
    pwm_module pwm(
        .clk(clk),
        .PWM_in(PWM),
        .PWM_out(AUD_PWM)
    );
    */
    
    pwm #(.WIDTH(ADC_WIDTH)) pwm_0 (
        .clk(clk),
        .reset(reset),
        .PWM_in(PWM),
        .PWM_out(AUD_PWM)
    );

endmodule
