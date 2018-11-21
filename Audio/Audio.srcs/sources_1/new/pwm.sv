`timescale 1ns / 1ps

module pwm #(parameter WIDTH=12) (
    input logic clk,
    input logic reset,
    input logic [WIDTH-1:0] PWM_in, 
    output logic PWM_out
    );

    logic [11:0] new_pwm;
    logic [11:0] PWM_ramp;
    
    always_ff @(posedge clk) begin
        
        if (reset) begin
            new_pwm <= 0;
            PWM_ramp <= 0;
            PWM_out <= 0;
        end
        
        // 
        else begin
            if (PWM_ramp == 0) new_pwm <= PWM_in;
            PWM_ramp <= PWM_ramp + 1'b1;
            PWM_out <= (new_pwm > PWM_ramp);
        end
    end

endmodule
