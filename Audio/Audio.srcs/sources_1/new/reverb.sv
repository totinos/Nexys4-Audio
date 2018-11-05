`timescale 1ns / 1ps

module reverb #(parameter N=16, DELAY=16) (
    input logic clk,
    input logic clk2,
    input logic reset,
    input logic ready,
    input logic [N-1:0] audio_in,
    output logic [N-1:0] audio_out
    );
    
    parameter ADDRESS_LIMIT = (1 << DELAY) - 1;
    
    logic [N-1:0] delay_in;
    logic [N-1:0] delay_out;
    logic [DELAY-1:0] write_addr;
    logic [DELAY-1:0] read_addr;
    
    // Instantiate a 2-port RAM module
    SRAM #(.DATA_WIDTH(N), .ADDR_WIDTH(DELAY-1), .LOG_DEPTH(DELAY)) block_ram (
        .clk(clk2),
        .write_enable(ready),
        .read_addr(read_addr),
        .write_addr(write_addr),
        .input_data(delay_in),
        .output_data(delay_out)
    );
    
    always_ff @(posedge clk) begin
        
        // On reset signal, reset
        if (reset) begin
            audio_out <= audio_in;
            delay_in <= audio_in;
            write_addr <= 0;
            read_addr <= 1;
        end
        
        // Otherwise delay the audio signal
        else begin
            if (ready) begin
            
                // Get incoming signal sample
                delay_in <= audio_in;
                
                // Check for write_addr overflow
                if (write_addr == ADDRESS_LIMIT) write_addr <= 0;
                else write_addr <= write_addr + 1;
                
                // Check for read_addr overflow
                if (read_addr == ADDRESS_LIMIT) read_addr <= 0;
                else read_addr <= read_addr + 1;
                
                // Sum the current and delayed signals (shift to decrease amplitude)
                audio_out <= audio_in + (delay_out >> 1);
                //audio_out <= delay_out >> 1;
            end
            else begin
                audio_out <= audio_in;
            end
        end
    end
    
endmodule
