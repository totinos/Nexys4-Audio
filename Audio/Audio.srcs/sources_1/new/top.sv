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


module top(
    input CLK100MHZ,
    
//XADC guitar input
    input vauxp3,
    input vauxn3,

    output AUD_PWM,
    output AUD_SD
    );

    wire [15:0] chipTemp;
    wire [15:0] aux_in;
    wire data_flag =1;
    reg [15:0] PWM;

    AnalogXADC xadc(
        .aux_data(aux_in),  
        .temp_data(chipTemp),
        .vauxp3(vauxp3),
        .vauxn3(vauxn3),
        .CLK100MHZ(CLK100MHZ)
    );
    
    always@(posedge(CLK100MHZ))begin 
        if (data_flag==1)begin
            PWM<=aux_in;
            end
    end
    assign AUD_SD = 1'b1;
    
    pwm_module pwm(
        .clk(CLK100MHZ),
        .PWM_in(PWM),
        .PWM_out(AUD_PWM)
    );

endmodule
