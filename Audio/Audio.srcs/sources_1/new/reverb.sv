`timescale 1ns / 1ps

/**********************************************************/
/*  A module to implement a looper by storing separate    */
/*  audio samples in Block RAM and playing them back      */
/*  sequentially.                                         */
/**********************************************************/
module reverb #(parameter N=12, DELAY=16) (
    input logic clk_100MHz,
    input logic clk_loop,
    input logic reset,
    input logic ready,
    input logic [N-1:0] audio_in,
    output logic [N-1:0] audio_out,
    output logic ready_internal_out
    );
    
    int ADDRESS_LIMIT = (1 << (DELAY-1)) - 1;
    
    logic [N-1:0] loop_in;
    logic [N-1:0] loop_out;
    logic [DELAY-1:0] write_addr;
    logic [DELAY-1:0] read_addr;
    logic ready_internal;
    logic rising_edge;
    logic falling_edge;
    logic ready_reg;
    
    // Instantiate a 2-port RAM module
    SRAM #(.DATA_WIDTH(N), .ADDR_WIDTH(DELAY), .LOG_DEPTH(DELAY)) block_ram (
        .clk(clk_loop),
        .write_enable(ready_internal),
        .read_addr(read_addr),
        .write_addr(write_addr),
        .input_data(loop_in),
        .output_data(loop_out)
    );
    
    // A rising/falling edge detector
    always_ff @(posedge clk_loop) begin
        ready_reg <= ready;
        
        // Reset the edge detector
        if (reset) begin
            ready_reg <= 0;
            rising_edge <= 0;
            falling_edge <= 0;
        end
        
        // Detect edges
        else begin
            if (ready & (!ready_reg)) rising_edge <= 1;
            else rising_edge <= 0;
                
            if ((!ready) & ready_reg) falling_edge <= 1;
            else falling_edge <= 0;
        end
    end
    
    always_ff @(posedge clk_loop) begin
        
        // On reset signal, reset
        if (reset) begin
            audio_out <= audio_in;
            loop_in <= audio_in;
            write_addr <= 0;
            read_addr <= 1;
            ready_internal <= 0;
            ready_internal_out <= 0;
        end
        
        // Otherwise delay the audio signal
        else begin
        
            // Setup on rising and falling edges
            if (rising_edge) begin
                write_addr <= 0;
                ready_internal <= 1;
                ready_internal_out <= 1;
                ADDRESS_LIMIT <= (1 << (DELAY-1)) - 1;
            end
            if (falling_edge || (write_addr == ADDRESS_LIMIT-1))  begin
                ADDRESS_LIMIT <= write_addr;
                ready_internal <= 0;
                ready_internal_out <= 0;
                read_addr <= 0;
                write_addr <= 0;
            end
        
            // Write loop to the Block RAM
            if (ready_internal) begin
            
                // Get incoming signal sample and increment write address
                loop_in <= audio_in;
                write_addr <= write_addr + 1;
                
                // Send the audio through
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
