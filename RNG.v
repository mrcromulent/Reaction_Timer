//RNG generates psuedo-random 14-bit numbers using a Fibonacci Linear Feedback Shift Register, with taps determined by the 
//polynomial given here https://www.xilinx.com/support/documentation/application_notes/xapp210.pdf. A series of XOR operations 
//on these taps results in a feedback bit which becomes the most significant bit of the next psuedo-random number. The output 
//of this process is then scaled so that it always falls between 1000 and 5000 (ms). This becomes the random wait time. See the
//References of the main report for more details.

module RNG(
    //RNG takes as clk the 100MHz clock. A new value will be generated with this frequency.
    input clk,
    input enable,
    input reset,
    output reg [13:0] outRND = `RNG_DEFAULT
    );
    
    //Declare a wire, feedback, to modify the random reg 'rnd'
    wire feedback;
    reg [13:0] rnd = `RNG_DEFAULT;
    
    //Assign the value of feedback using the polynomial for a 14-bit Fibonacci LFSR. 
    assign feedback = ((((rnd[0]) ^ (rnd[1])) ^ (rnd[2])) ^ (rnd[11])) ^ rnd[13];
    
    always @(posedge clk) begin
        if (reset) //Reset to a value in the correct range if directed
            rnd = `RNG_DEFAULT;
               
        else if (enable) //If enabled, bit shift rnd and add the feedback bit as the MSB 
            rnd = {feedback,rnd[13:1]};
            //The RNG_LOWER_BOUND and %RNG_MODULO_DIVISOR ensure the output value is on the order of 1-5 seconds
            outRND = `RNG_LOWER_BOUND + rnd % `RNG_MODULO_DIVISOR;
    
    end
    
endmodule
