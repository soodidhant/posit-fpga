// =============================================================================
// Module  : LBC (Leading Bit Counter)
// Project : Posit Encoder/Decoder
// Authors : Abhinav Nagpal, Idhant Sood
//
// Description:
//   Counts the number of leading identical bits in the regime field.
//   The first bit (msb) sets the polarity; count includes all consecutive
//   bits matching that polarity.
//
//   Used by the Decoder to determine regime length and value k.
// =============================================================================

module LBC (
    input  wire [13:0] in,
    output reg         msb,
    output reg  [3:0]  count
);

    integer i;

    always @(*) begin
        msb   = in[13];
        count = 4'd0;

        for (i = 12; i >= 0; i = i - 1) begin
            if (in[i] == in[13] && count == (13 - i))
                count = count + 4'd1;
        end
        // count = number of bits matching msb, starting from bit 13
        // Final count includes the leading bit itself
        count = count + 4'd1;
    end

endmodule
