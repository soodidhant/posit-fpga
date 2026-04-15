// =============================================================================
// Module  : MUX14 (14-bit Barrel Shift Multiplexer)
// Project : Posit Encoder/Decoder
// Authors : Abhinav Nagpal, Idhant Sood
//
// Description:
//   Left-shifts the 14-bit posit body by `sel` positions, exposing the
//   exponent and mantissa fields at the MSB end.
//   Used by the Decoder after regime extraction.
// =============================================================================

module MUX14 (
    input  wire [13:0] in,
    input  wire  [3:0] sel,
    output wire [13:0] out
);

    // Barrel shift: out = in << sel (logical, fill with 0)
    assign out = in << sel;

endmodule
