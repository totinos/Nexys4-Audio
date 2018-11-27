
module disto #(parameter N=12, threshold = 1500, thresholdLow = 100, distortionThreshHigh = 3000, distortionThreshLow = 10) (
                    input logic clk,
                    input logic reset,
                    input logic ready,
                    input logic [N-1:0] audio_in,
                    output logic [N-1:0] audio_out
);


always @(posedge clk) begin
    if (ready) begin
        if (audio_in > distortionThreshHigh) audio_out <= distortionThreshHigh;
        if (audio_in < distortionThreshLow) audio_out <= distortionThreshLow;
        if (audio_in <= distortionThreshHigh && audio_in >= distortionThreshLow) audio_out <= audio_in;
    end
    else audio_out <= audio_in;
end
endmodule
