`timescale 1ns / 1ps

/**********************************************************/
/*  A top module to connect all the different components  */
/*  of the design.                                        */
/**********************************************************/
module top #(parameter ADC_WIDTH=16) (
    input clk,
    input logic reset,
    input logic ready1,
    input logic ready2,
    input logic ready3,
    input logic [3:0] clk_div_switches,
    
    //XADC guitar input
    input logic vauxp3,
    input logic vauxn3,

    output logic AUD_PWM,
    output logic AUD_SD,
    
    output logic led_test
    );

//    logic clk_25MHz;
    logic cdiv_out;
    logic clk_delay;

    logic [ADC_WIDTH-1:0] aux_in;
    logic [ADC_WIDTH-5:0] aux_in1;
    logic [ADC_WIDTH-5:0] aux_out;
    logic [ADC_WIDTH-5:0] aux_out1;
    logic [ADC_WIDTH-5:0] aux_out2;

    logic [ADC_WIDTH-1:0] chipTemp;
    logic [ADC_WIDTH-5:0] PWM;
    
//    Instantiate a clock divider
    clk_div #(.NUM_DIVISIONS(9)) cdiv_delay (
        .clk_in(clk),
        .reset(reset),
        .clk_out(clk_delay)
    );
    
    // Instantiate a clock manager to switch between divided clocks
    clk_manager cdiv (
        .clk_100MHz(clk),
        .reset(reset),
        .switches(clk_div_switches),
        .clk_out(cdiv_out)
    );

//    clk_div_2 cdiv (
//        .clk_in(clk),
//        .reset(reset),
//        .select(clk_div_switches),
//        .clk_out(cdiv_out)
//    );
    
    // Instantiate an ADC to sample audio input
    AnalogXADC xadc (
        .aux_data(aux_in),  
        .temp_data(chipTemp),
        .vauxp3(vauxp3),
        .vauxn3(vauxn3),
        .CLK100MHZ(clk)
    );
    
    // Use the top 12 bits from the ADC as the audio input
    assign aux_in1 = aux_in[15:4];
    
    // Instantiate a module to distort the audio signal
    disto top_disto (
        .clk(clk),
        .reset(reset),
        .ready(ready1),
        .audio_in(aux_in1),
        .audio_out(aux_out)
    );
 
    // Instantiate a module to delay the audio signal
    delay #(.DELAY(17)) top_delay (
        .clk_100MHz(clk),
        .clk_delay(cdiv_out),
        .reset(reset),
        .ready(ready2),
        .audio_in(aux_out),
        .audio_out(aux_out1)
    );
    
    // Instantiate a module for reverb
    reverb #(.DELAY(19)) top_reverb(
        .clk_100MHz(clk),
        .clk_loop(cdiv_out),        
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
    
    // Drive the audio output with a pulse width modulated signal
    pwm #(.WIDTH(ADC_WIDTH-4)) pwm_0 (
        .clk(clk),
        .reset(reset),
        .PWM_in(PWM),
        .PWM_out(AUD_PWM)
    );

endmodule
