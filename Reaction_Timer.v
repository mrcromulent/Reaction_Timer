//Reaction_Timer controls the timing during the TEST state. It increments the reaction_time counter with 1kHz frequency, 
//returning the user's reaction_time as a 14-bit reg representing the reaction time in miliseconds. If the user takes
//longer than 9999 ms to react, test_timeout returns TRUE.

module Reaction_Timer(
    input wire [2:0] current_state,
    input wire clock,
    input wire rising_edge_1khz,
    output reg [13:0] reaction_time,
    output wire test_timeout
    );
    
    //If in the TEST state, increment up the reaction_time by 1 (ms)
    always @(posedge clock) begin
        if(current_state == `STATE_TEST) begin
            if(rising_edge_1khz) begin
                reaction_time <= reaction_time + 1;
            end
        end else if (current_state == `STATE_PREP) begin
            reaction_time <= 0;
        end
    end
    
    //If the user hasn't reacted in 10s, return test_timeout = TRUE
    assign test_timeout = reaction_time > `TEST_TIMEOUT;
    
endmodule
