
module disto #(parameter N=16, threshold = 1000, thresholdLow = 150, distortionThreshHigh = 2000, distortionThreshLow = 200) (
                    input logic clk,
                    input logic reset,
                    input logic ready,
                    input logic [N-1:0] audio_in,
                    output logic [N-1:0] audio_out
);


always @(posedge clk) begin
    if (ready) begin
        if (audio_in > distortionThreshHigh) audio_out <= distortionThreshHigh;
        else if (audio_in < distortionThreshLow) audio_out <= distortionThreshLow;
        else audio_out <= audio_in;
    end
    else if (audio_in > threshold) audio_out <= threshold;
    else if (audio_in < thresholdLow) audio_out <= thresholdLow;
    else audio_out <= audio_in;

end
endmodule
