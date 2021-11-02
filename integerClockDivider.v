//integerClockDivider creates a 1kHz clock signal using the 100MHz input signal and incrementing up a reg, counter, every cycle
//of this master clock. By flipping the value of the reg dividedClk every time counter reaches 50_000_000 - 1, dividedClk
//will change with the equivalent of 1kHz of frequency. This is directly based on the code from Lab 2.

module integerClockDivider #(
    parameter integer THRESHOLD = 50_000_000
)(
    //clk is the 100MHz master clock
    input wire clk,
    input wire reset,
    input wire enable,
    output reg dividedClk
    );
    
    reg [31:0] counter;
    
    //When counter reaches the overflow value of THRESHOLD - 1, it is reset. Else, it is just incremented by 1.
    always @(posedge clk) begin
        if (reset == 1 || counter >= THRESHOLD - 1 ) begin
            counter = 0;
        end else if (enable == 1) begin
            counter = counter + 1;
        end
    end
    
    //Inversion of dividedClk when the overflow value of THRESHOLD - 1 is reached
    always @(posedge clk) begin
        if (reset == 1 ) begin
            dividedClk = 0;
        end else if (counter >= THRESHOLD - 1) begin
            dividedClk = ~dividedClk;
        end
    end
    
endmodule
