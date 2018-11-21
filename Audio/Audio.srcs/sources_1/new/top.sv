`timescale 1ns / 1ps

module top #(parameter ADC_WIDTH=16) (
    input clk,
    input logic reset,
    input logic ready1,
    input logic ready2,
    input logic ready3,
    
    //XADC guitar input
    input logic vauxp3,
    input logic vauxn3,

    output logic AUD_PWM,
    output logic AUD_SD,
    
    output logic led_test
    );

    logic clk_25MHz;

    logic [ADC_WIDTH-1:0] aux_in;
    logic [11:0] aux_in1;
    logic [11:0] aux_out;
    logic [11:0] aux_out1;
    logic [11:0] aux_out2;

    logic [11:0] chipTemp;
    logic [11:0] PWM;
    
    //Instantiate a clock divider
    clk_div #(.NUM_DIVISIONS(9)) cdiv (
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
    
    assign aux_in1 = aux_in[15:4];
    
    disto top_disto (
        .clk(clk),
        .reset(reset),
        .ready(ready1),
        .audio_in(aux_in1),
        .audio_out(aux_out)
    );
    
 
    // Instantiate a module to delay the audio signal
    delay #(.DELAY(17)) top_delay (
        .clk(clk_25MHz),
        .clk2(clk),
        .reset(reset),
        .ready(ready2),
        .audio_in(aux_out),
        .audio_out(aux_out1)
    );
    
    // Instantiate a module for reverb
    reverb #(.DELAY(19)) top_reverb(
        .clk(clk_25MHz),
        .clk2(clk),        
        .reset(reset),
        .ready(ready3),
        .audio_in(aux_out1),
        .audio_out(aux_out2),
        .ready_internal_out(led_test)
    );
    
    
    // Connect delay module output to PWM 
    always_ff @(posedge clk) begin
        PWM <= aux_out2;
    end
    
    // Enable the audio output port
    assign AUD_SD = 1'b1;
    
    pwm #(.WIDTH(ADC_WIDTH)) pwm_0 (
        .clk(clk),
        .reset(reset),
        .PWM_in(PWM),
        .PWM_out(AUD_PWM)
    );

endmodule
