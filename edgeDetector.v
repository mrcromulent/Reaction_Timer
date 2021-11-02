//edgeDetector is designed to catch the risingEdge condition of the 1kHz clock, using the 100MHz clock for timing. edgeDetector 
// does this by holding the value at the clock's (signalIn's) posedge as SignalOut. The rising edge then simply occurs when the
// last signalOut value is 0 (before the clock went to HIGH) and the signalIn value is currently HIGH. 
//That is, signalIn & ~signalOut. This code is based on work from Lab 3.

module edgeDetector(
        //clk is the 100MHz clock and signalIn is the 1kHz clock.
        input clk,
        input signalIn,
        output risingEdge,
        output fallingEdge,
        output reg signalOut
    );

    //periodically sychronising the value of signalOut and signalIn.
    always @(posedge clk) begin
        signalOut = signalIn;
    end

    //risingEdge is true whenever the value of SignalIn quickly goes from 0 to 1 (i.e. the rising edge).
    assign risingEdge = signalIn & ~signalOut;
    assign fallingEdge = ~signalIn & signalOut;
    
endmodule
