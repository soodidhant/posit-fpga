// =============================================================================
// Module  : posit_top
// Project : Design and FPGA Implementation of Posit Encoder and Decoder
// Authors : Abhinav Nagpal (2210110111), Idhant Sood (2210110303)
//
// Description:
//   Top-level wrapper. Connects the Decoder and Encoder for round-trip
//   validation:  posit_in -> Decoder -> fields -> Encoder -> posit_out
//   ILA/VIO probes attach at the intermediate field signals.
// =============================================================================

module posit_top (
    input  wire [15:0] posit_in,
    output wire [15:0] posit_out,
    // Decoded field outputs (also monitored via VIO/ILA)
    output wire        sign,
    output wire [3:0]  regime,
    output wire [1:0]  exp,
    output wire [10:0] mantissa,
    output wire        ss,
    output wire        chck,
    output wire        saddcin
);

    // -----------------------------------------------------------------------
    // Decoder: posit binary -> constituent fields
    // -----------------------------------------------------------------------
    Decoder u_decoder (
        .posit_in  (posit_in),
        .sign      (sign),
        .regime    (regime),
        .exp       (exp),
        .mantissa  (mantissa),
        .ss        (ss),
        .chck      (chck),
        .saddcin   (saddcin)
    );

    // -----------------------------------------------------------------------
    // Encoder: constituent fields -> posit binary (round-trip check)
    // -----------------------------------------------------------------------
    Encoder u_encoder (
        .sign      (sign),
        .regime    (regime),
        .exp       (exp),
        .mantissa  (mantissa),
        .ss        (ss),
        .posit_out (posit_out)
    );

endmodule
