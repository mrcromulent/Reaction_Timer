//This top-level module contains the instantiations of all submodules (e.g. Prep_Timer and Time_Decoder) and creates
//other quantities used by the submodules (e.g. the 1kHz divided clock). It also contains a case statement which sets 
//time_to_display depending on the current state.

module Reaction_Timer_TOP(

    //User-controlled buttons
    input wire start_button,
    input wire stop_button,
    input wire reset,
    input wire dev_mode,
    
    //Declare a clock to be divided and used for timing purposes
    input wire CLK100MHZ,
    
    //Declare outputs which will hold display information for the SSDs
    output [0:3] ssdAnode,
    output [6:0] ssdCathode,
    output ssdDecimal,
    output [15:0] LED
    );
    
    //Set default display variables on boot
    reg [13:0] cur_time = `FAIL;
    
    //Declare timing wires, including the divided clock (CLK1KHZ), its rising edge, the current state, timeouts and the user's 
    //reaction time. The time_to_display reg is passed to a Time_Decoder module for display on the SSDs and is modified
    //based on the current state.
    wire CLK1KHZ;
    wire CLK5HZ;
    wire ssd_enable;
    wire rising_edge_1khz;
    wire [2:0] current_state;
    wire [13:0] countdown;
    wire prep_timeout;
    wire test_timeout;
    wire [13:0] reaction_time;
    reg [13:0] time_to_display;
    wire is_high_score;
    
    assign ssd_enable = CLK5HZ || ~is_high_score;

    //Instantiate the lower-level modules
    
    //integerClockDivider gives us a 1kHz clock from our 100MHz clock
    integerClockDivider #(
        .THRESHOLD(50_000)
    ) CLOCK_1KHZ_GENERATOR (
        .clk(CLK100MHZ),
        .reset(0),
        .enable(1),
        .dividedClk(CLK1KHZ)
    );
    
    integerClockDivider #(
        .THRESHOLD(10_000_000)
    ) CLOCK_5HZ_GENERATOR (
        .clk(CLK100MHZ),
        .reset(0),
        .enable(1),
        .dividedClk(CLK5HZ)
    );
    
    //edgeDetector allows us to catch the rising edge of the 1kHz clock for timing purposes in the Reaction_Timer and
    //Prep_Timer modules 
    edgeDetector CLOCK_1KHZ_EDGE (
       .clk(CLK100MHZ),
       .signalIn(CLK1KHZ),
       .signalOut(),
       .risingEdge(rising_edge_1khz),
       .fallingEdge()
    );
    
    //Time_Decoder controls display on the SSDs, setting the anode and cathode voltages based on the user's score or FAIL
    Time_Decoder (
        .time_millisecs(time_to_display),
        .clock(CLK100MHZ),
        .rising_edge_1khz(rising_edge_1khz),
        .enable(ssd_enable),
        .ssd_anode(ssdAnode),
        .ssd_cathode(ssdCathode),
        .ssd_decimal(ssdDecimal)
    );
    
    //FSM controls transitions between the various states of the reaction timer. Its behaviour is influlenced by the the 
    //current state, the user's input and its clock input.
    FSM (
        .clock(CLK100MHZ),
        .start_button(start_button),
        .stop_button(stop_button),
        .reset(reset),
        .enable(1),
        .prep_timeout(prep_timeout),
        .test_timeout(test_timeout),
        .rising_edge_1khz(rising_edge_1khz),
        .current_state(current_state)
    );
    
    //Prep_Timer allows for the display of the 3,2,1 preamble and  contains a submodule, RNG, to generate a random wait time
    // before activation of the LEDs (i.e. the onset of STATE_TEST)
    Prep_Timer (
        .clock(CLK100MHZ),
        .rising_edge_1khz(rising_edge_1khz),
        .current_state(current_state),
        .countdown(countdown),
        .timeout(prep_timeout)
    );
    
    //Reaction_Timer increments the reaction_time counter and checks for the 10s timeout condition
    Reaction_Timer (
        .current_state(current_state),
        .clock(CLK100MHZ),
        .rising_edge_1khz(rising_edge_1khz),
        .reaction_time(reaction_time),
        .test_timeout(test_timeout)
    );
    
    //Set the value of time_to_display based on the current state.
    //-For IDLE, this should be 0, for PREP, this should be the 3,2,1 countdown
    //-For TEST, this should be the user's reaction time (which will be counting up)
    //-For TEST_RESULT_OK, this will be the reaction time when the button was pressed and for RESULT_FAIL, this will be the 
    //text 'FAIL'
    
    always @(*) begin
        case (current_state)
        `STATE_IDLE : time_to_display <= `IDLE;
        `STATE_PREP : time_to_display <= countdown;
        `STATE_TEST : time_to_display <= reaction_time;
        `STATE_RESULT_OK : time_to_display <= reaction_time;
        `STATE_RESULT_FAIL : time_to_display <= `FAIL;
        default : time_to_display <= 0;
       endcase
    end
    
    //Set some reserved LEDs for use in the developer mode. They show the current state (i.e. IDLE, PREP, TEST, etc.)
    //This information is shown if developer mode is enabled only.
    LED_Controller (
        .dev_mode(dev_mode),
        .current_state(current_state),
        .is_high_score(is_high_score),
        .LED(LED)
    );
    
    High_Scorer (
        .clock(CLK100MHZ),
        .current_state(current_state),
        .reaction_time(reaction_time),
        .reset(reset),
        .is_high_score(is_high_score)
    );
    
    
        
endmodule
