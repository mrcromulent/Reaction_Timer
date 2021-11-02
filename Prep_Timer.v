//Prep_Timer controls timing activities from the IDLE state to the very end of PREP (including the random wait time). Prep_Timer
//increments the timer at 1kHz frequency during this stage and returns timeout = TRUE when the random wait time finishes (i.e.
//at the moment the TEST state begins). It also uses the 1kHz clock to display the 3,2,1 preamble in the PREP state and returns
//the countdown as an output to the TOP module.

module Prep_Timer(
    input wire clock,
    input wire rising_edge_1khz,
    input wire [2:0] current_state,
    output reg [13:0] countdown,
    output wire timeout 
    );
    
    wire [13:0] threshold;
    wire [13:0] random_number;
    reg [13:0] timer;
    reg [13:0] random_wait;
    
    //Instantiate RNG and assign the resulting random number to the wire random_number
    RNG (
        .clk(clock),
        .enable(1),
        .reset(0),
        .outRND(random_number)
    );
    
    //Set timeout to true when timer exceeds the 3 second countdown and the random wait
    assign threshold = 14'd3000 + random_wait;
    assign timeout = timer > threshold;
    
    //Increment the timer in the PREP state
    always @(posedge clock) begin
        if (current_state == `STATE_IDLE) begin
            timer <= 0;
            random_wait <= random_number;
        end else if(current_state  == `STATE_PREP && rising_edge_1khz) begin
            timer <= timer + 1;
        end
    end
    
    //set the value of countdown to display 3,2,1 on the SSDs
    always @(posedge clock) begin
        if(timer < 1000)
            countdown <= 3;
        else if (timer < 2000)
            countdown <= 2;
        else if (timer < 3000)
            countdown <= 1;
        else
            countdown <= `LED_BLANK;
    end
    
    
endmodule
