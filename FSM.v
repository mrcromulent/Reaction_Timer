// FSM (Finite State Machine) controls transitions between the various states during a full test, including IDLE, PREP, TEST
//and RESULT (RESULT_FAIL and RESULT_OK). It outputs the current state. When the user presses the start, stop or reset buttons,
//this signal is sent to this module to determine what the appropriate next state should be, based on the current state.

module FSM(
    input wire clock,
    input wire start_button,
    input wire stop_button,
    input wire reset,
    input wire enable,
    input wire prep_timeout,
    input wire test_timeout,
    input wire rising_edge_1khz,
    
    output reg [2:0] current_state
    );
    
    reg [2:0] next_state = 0;
    reg [13:0] counter;

    // STATE TRANSITION LOGIC - A reset signal will send the system back to IDLE
    always @(posedge clock) begin  
        if(reset) begin
            current_state = `STATE_IDLE;
        end else begin 
            current_state <= next_state;
        end
    end
    
    // NEXT STATE LOGIC
    always @(*) begin
        
        //If the start button is pressed in IDLE state, proceed to PREP state
        case(current_state)
        `STATE_IDLE : begin
            if(start_button) begin
                next_state <= `STATE_PREP;
            end else begin
                next_state <= `STATE_IDLE;
            end
        end
        
        //If in PREP state, fail the user if they press the stop button and advance them to TEST as soon as prep_timeout is
        //exceeded 
        `STATE_PREP : begin
            if(prep_timeout) begin
                next_state <= `STATE_TEST;
            end else if (stop_button) begin
                next_state <= `STATE_RESULT_FAIL;
            end else begin
                next_state <= `STATE_PREP;
            end
        end
        
        //In TEST state, send the user to RESULT_OK if they press the stop button, unless the test times out, in which case,
        //send them to RESULT_FAIL
        `STATE_TEST : begin
            if(stop_button) begin
                next_state <= `STATE_RESULT_OK;
            end else if(test_timeout) begin
                next_state <= `STATE_RESULT_FAIL;
            end else begin
                next_state <= `STATE_TEST;
            end
        end
        
        //If in RESULT_OK, send the user back to IDLE if they reset or they have waited longer than 10s. This is the 
        //same for RESULT_FAIL
        `STATE_RESULT_OK : begin
            if(start_button) begin
                next_state <= `STATE_IDLE;
            end else if(counter > `RESULT_TIMEOUT) begin
                next_state <= `STATE_IDLE;
            end else begin
                next_state <= `STATE_RESULT_OK;
            end
        end
        
        `STATE_RESULT_FAIL : begin
            if(start_button) begin
                next_state <= `STATE_IDLE;
            end else if(counter > `RESULT_TIMEOUT) begin
                next_state <= `STATE_IDLE;
            end else begin
                next_state <= `STATE_RESULT_FAIL;
            end
        end
        
        default : begin
            next_state <= `STATE_IDLE;
        end
        
        endcase
    end
    
    
    //Increment the counter at the posedge of the 1kHz clock. This allows the program to return to IDLE after 10s in RESULT.
    always @(posedge clock) begin
        case (current_state)
        `STATE_IDLE : begin
            counter <= 0;
        end
        `STATE_RESULT_OK : begin
            if(rising_edge_1khz) counter <= counter + 1;
        end
        `STATE_RESULT_FAIL : begin
            if(rising_edge_1khz) counter <= counter + 1;
        end
        endcase
    end
    
    
endmodule
