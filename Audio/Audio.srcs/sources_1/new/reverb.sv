`timescale 1ns / 1ps

module reverb #(parameter N=12, DELAY=16) (
    input logic clk,
    input logic clk2,
    input logic reset,
    input logic ready,
    input logic [N-1:0] audio_in,
    output logic [N-1:0] audio_out,
    output logic ready_internal_out
    );
    
    int ADDRESS_LIMIT = (1 << DELAY) - 1;
    
    logic [N-1:0] loop_in;
    logic [N-1:0] loop_out;
    logic [DELAY-1:0] write_addr;
    logic [DELAY-1:0] read_addr;
    logic readyInternal;
    logic rising_edge;
    logic falling_edge;
    logic readyReg;
    
    // Instantiate a 2-port RAM module
    SRAM #(.DATA_WIDTH(N), .ADDR_WIDTH(DELAY-1), .LOG_DEPTH(DELAY)) block_ram (
        .clk(clk2),
        .write_enable(readyInternal),
        .read_addr(read_addr),
        .write_addr(write_addr),
        .input_data(loop_in),
        .output_data(loop_out)
    );
    
    // A rising/falling edge detector
    always_ff @(posedge clk) begin
        readyReg <= ready;
        
        // Reset the edge detector
        if (reset) begin
            readyReg <= 0;
            rising_edge <= 0;
            falling_edge <= 0;
        end
        
        // Detect edges
        else begin
            if (ready & (!readyReg)) rising_edge <= 1;
            else rising_edge <= 0;
                
            if ((!ready) & readyReg) falling_edge <= 1;
            else falling_edge <= 0;
        end
    end
    
    always_ff @(posedge clk) begin
        
        // On reset signal, reset
        if (reset) begin
            audio_out       <= audio_in;
            loop_in         <= audio_in;
            write_addr      <= 0;
            read_addr       <= 1;
            readyInternal   <= 0;
            ready_internal_out <= 0;
        end
        
        // Otherwise delay the audio signal
        else begin
        
            // Setup on rising and falling edges
            if (rising_edge) begin
                write_addr      <= 0;
                readyInternal   <= 1;
                ready_internal_out <= 1;
                ADDRESS_LIMIT   <= (1 << DELAY) - 1;
            end
            if (falling_edge || (write_addr == ADDRESS_LIMIT))  begin
                readyInternal   <= 0;
                ready_internal_out <= 0;
                read_addr       <= 0;
                write_addr      <= 0;
            end
        
            // Write loop to the Block RAM
            if (readyInternal) begin
            
                // Get incoming signal sample
                loop_in <= audio_in;
                
                // Check for write_addr overflow
                write_addr <= write_addr + 1;
                
                // Sum the current and delayed signals (shift to decrease amplitude)
                audio_out <= audio_in;
            end
            
            // Read the stored loop from Block RAM
            else begin
            
                // Check for read_addr overflow
                if (read_addr == ADDRESS_LIMIT) read_addr <= 0;
                else read_addr <= read_addr + 1;
                
                // Add the stored loop to the current audio input
                audio_out <= audio_in + loop_out;
                
            end
        end
    end
    
endmodule
