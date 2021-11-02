//High_Scorer takes the current reaction_time and state and produces a wire, is_high_score, whose value is true if the score is
//the highest since the most recent reset. If only one score exists since the most recent reset, it is a high score by default.

module High_Scorer(
    input wire clock,
    input wire [2:0] current_state,
    input wire [13:0] reaction_time,
    input wire reset,
    
    //Declare is_high_score as an output wire
    
    output wire is_high_score
    );
    
    //Set the default high score at the maximum reaction time value and reset to this value if RESET is pressed
    
    reg [13:0] current_high_score = 14'd9999;
    
    always @(posedge clock) begin
        if (reset)
            current_high_score = 14'd9999;
            
        //If the current reaction time is better than the previous, make this the new high score
        else if (current_state == `STATE_RESULT_OK && reaction_time < current_high_score) begin
            current_high_score = reaction_time;
        end
    end
    
    //is_high_score is true only if the current high score is identical to the current reaction time. That is, if it was 
    //just scored
    assign is_high_score = (current_state == `STATE_RESULT_OK) && (current_high_score == reaction_time);
    
endmodule
