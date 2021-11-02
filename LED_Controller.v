//LED_Controller takes the current_state and displays it on the FPGA's LEDs (15 to 11), but only if dev_mode is enabled by 
//the user. It also lights up LEDs 8 to 0 as soon as the TEST mode becomes true.

module LED_Controller(
    input wire [2:0] current_state,
    input wire dev_mode,
    input wire is_high_score,
    output reg [15:0] LED
    );
    
    //Turn on the correct LED based on the value of current_state
    always @(*) begin
        if (dev_mode) begin
            LED[15] = (current_state == `STATE_IDLE);
            LED[14] = (current_state == `STATE_PREP);
            LED[13] = (current_state == `STATE_TEST);
            LED[12] = (current_state == `STATE_RESULT_OK);
            LED[11] = (current_state == `STATE_RESULT_FAIL);
            LED[10] = is_high_score;
            LED[9]  = 0;
        end else begin
            LED[15:9] = 7'b1111111 * (current_state == `STATE_TEST);
        end
        
       //As soon as the device enters TEST mode, light up LEDs 8 to 0.
        LED[8:0] = 9'b111111111 * (current_state == `STATE_TEST);    

    end
    
    
    
endmodule
