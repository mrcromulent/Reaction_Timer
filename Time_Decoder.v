//Time_Decoder takes as input the user's reaction time in miliseconds and controls the display on the SSDs, using ssd_anode,
//ssd_cathode and ssd_decimal. These are sent directly to the FPGA's SSDs and display the reaction time, countdown and 'FAIL'
//message. Only one SSD is being illuminated at a time but the 'active_ssd' is represented by an overflow counter that changes
//with 1kHz frequency, so this is not perceivable by the eye.

module Time_Decoder(
    input wire [13:0] time_millisecs,
    input wire clock,
    input wire rising_edge_1khz,
    input wire enable,
    
    output reg [0:3] ssd_anode,
    output wire [6:0] ssd_cathode,
    output reg ssd_decimal
    );
        
    //The overflow counters
    reg [1:0] active_ssd = 0;
    reg [4:0] ssd_number = 0;
    
    //Incrementing the overflow counter
    always @(posedge clock) begin
        if(rising_edge_1khz)
            active_ssd <= active_ssd + 1;
    end
    
    //If the user failed, display this. Note the decimal point is not activated. If `LED_BLANK, the SSDs will be blank as well.
    //Case statements are used to cycle the active SSD.
    always @(*) begin
        if (time_millisecs == `FAIL) begin
            ssd_decimal = 1;
            case (active_ssd)
                2'd0 : ssd_number = `SSD_L;
                2'd1 : ssd_number = `SSD_I;
                2'd2 : ssd_number = `SSD_A;
                2'd3 : ssd_number = `SSD_F;
            endcase
        end else if (time_millisecs == `IDLE) begin
            ssd_decimal = 1;
            case (active_ssd)
                2'd0 : ssd_number = `SSD_E;
                2'd1 : ssd_number = `SSD_L;
                2'd2 : ssd_number = `SSD_D;
                2'd3 : ssd_number = `SSD_I;
            endcase
        end else if (time_millisecs == `LED_BLANK) begin
            ssd_decimal = 1;
            ssd_number = `SSD_OFF;
        
        //For the case where a numerical reaction time has been received (RESULT_OK), extract the relevant digits (units, tens,
        //hundreds etc.) and assign them to the correct SSD.
        end else begin
            ssd_decimal = (active_ssd != 2'd3);
            case (active_ssd)
                2'd0 : ssd_number = time_millisecs % 10;
                2'd1 : ssd_number = (time_millisecs / 10) % 10;
                2'd2 : ssd_number = (time_millisecs / 100) % 10;
                2'd3 : ssd_number = (time_millisecs / 1000) % 10;
            endcase
        end
    end
    
    //The SSD's anode must then be set depending on which SSD is illuminated. This case statement does this based on the 
    //active-low configuration of the FPGA board.
    always @(*) begin
        if(enable) begin
            case (active_ssd)
                2'd0 : ssd_anode = 4'b1110;
                2'd1 : ssd_anode = 4'b1101;
                2'd2 : ssd_anode = 4'b1011;
                2'd3 : ssd_anode = 4'b0111;
            endcase
        end else begin
            ssd_anode = 4'b1111;
        end
    end  
    
    //Instantiate SSD_decoder to determine the SSD's cathode configuration based on the binary-coded digit
    sevenSegmentDecoder SSD_decoder (
        .bcd(ssd_number),
        .ssd(ssd_cathode)
    );
    
endmodule
