// =============================================================================
// Module  : Subtractor
// Project : Posit Encoder/Decoder
// Authors : Abhinav Nagpal, Idhant Sood
//
// Description:
//   4-bit subtractor with borrow-in. Used for regime index calculations
//   and field alignment within the Decoder and Encoder pipelines.
// =============================================================================

module Subtractor (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire       bin,    // borrow in
    output wire [3:0] diff,
    output wire       bout    // borrow out
);

    wire [4:0] result;
    assign result = {1'b0, a} - {1'b0, b} - {4'b0, bin};
    assign diff   = result[3:0];
    assign bout   = result[4];

endmodule
