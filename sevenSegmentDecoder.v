//sevenSegmentDecoder takes a binary-coded digit, bcd, and assigns the seven-bit output, ssd, based on bcd's value. The value of
//ssd simply specifies which segments are to be illuminated in an active-low configuration. This module is directly based on 
//work from Lab 3.

module sevenSegmentDecoder(
    input [4:0] bcd,
    output reg [6:0] ssd
    );
    
    always @(*) begin
        case(bcd)
            5'd0 : ssd = 7'b0000001;
            5'd1 : ssd = 7'b1001111;
            5'd2 : ssd = 7'b0010010;
            5'd3 : ssd = 7'b0000110;
            5'd4 : ssd = 7'b1001100;
            5'd5 : ssd = 7'b0100100;
            5'd6 : ssd = 7'b0100000;
            5'd7 : ssd = 7'b0001111;
            5'd8 : ssd = 7'b0000000;
            5'd9 : ssd = 7'b0000100;
            5'd`SSD_F : ssd = 7'b0111000;
            5'd`SSD_A : ssd = 7'b0001000;
            5'd`SSD_I : ssd = 7'b1111001;
            5'd`SSD_L : ssd = 7'b1110001;
            5'd`SSD_E : ssd = 7'b0110000;
            5'd`SSD_D : ssd = 7'b1000010;
            5'd`SSD_OFF : ssd = 7'b1111111;
            default : ssd = 7'b0110110;
        endcase
    end
    
endmodule
