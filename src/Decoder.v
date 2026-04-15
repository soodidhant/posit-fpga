// =============================================================================
// Module  : Decoder
// Project : Design and FPGA Implementation of Posit Encoder and Decoder
// Authors : Abhinav Nagpal (2210110111), Idhant Sood (2210110303)
// Advisor : Dr. Rakesh Palisetty, Shiv Nadar Institution of Eminence
// Date    : November 2025
// Tool    : Xilinx Vivado 2025.1
// Device  : xc7a100tcsg324-1 (Artix-7)
//
// Description:
//   16-bit posit decoder. Extracts sign, regime (k value), exponent, and
//   mantissa/fraction fields from a raw 16-bit posit binary input.
//   Handles the special cases zero (all 0s) and NaR (MSB=1, rest 0).
//
//   Posit format:  [sign | regime | exponent(es bits) | fraction]
//   useed = 2^(2^es)   (es=2 for 16-bit posit in this design)
//
// Ports (derived from Vivado IO placement report):
//   Input  : posit_in  [15:0]  - 16-bit posit encoded number
//   Outputs: sign              - sign bit
//            regime    [3:0]   - decoded regime value (k)
//            exp       [1:0]   - exponent field (es=2)
//            mantissa  [10:0]  - fraction/mantissa bits
//            ss                - special-case flag (zero or NaR)
//            chck              - check/valid flag
//            saddcin           - carry-in signal for subtractor sub-block
// =============================================================================

module Decoder (
    input  wire [15:0] posit_in,
    output wire        sign,
    output wire [3:0]  regime,
    output wire [1:0]  exp,
    output wire [10:0] mantissa,
    output wire        ss,
    output wire        chck,
    output wire        saddcin
);

    // -------------------------------------------------------------------------
    // Sign extraction
    // -------------------------------------------------------------------------
    assign sign = posit_in[15];

    // -------------------------------------------------------------------------
    // Special case detection
    //   zero : posit_in == 16'h0000
    //   NaR  : posit_in == 16'h8000
    // -------------------------------------------------------------------------
    assign ss   = (posit_in == 16'h0000) || (posit_in == 16'h8000);

    // -------------------------------------------------------------------------
    // Two's complement for negative numbers
    //   Work on the magnitude: if sign=1, invert and add 1
    // -------------------------------------------------------------------------
    wire [15:0] mag;
    assign mag = sign ? (~posit_in + 1'b1) : posit_in;

    // -------------------------------------------------------------------------
    // Regime detection via Leading Bit Counter (LBC)
    //   After the sign bit, regime is a run of identical bits terminated by
    //   the opposite bit.
    //   regime_bit = mag[14] (first regime bit after sign)
    //   If regime_bit = 1 : count consecutive 1s  => k = count - 1
    //   If regime_bit = 0 : count consecutive 0s  => k = -(count)
    // -------------------------------------------------------------------------
    wire [13:0] regime_field;
    assign regime_field = mag[14:1];   // bits [14:1] after sign

    // LBC sub-module instantiation
    wire [3:0]  lbc_count;
    wire        regime_msb;

    LBC lbc_inst (
        .in     (regime_field),
        .msb    (regime_msb),
        .count  (lbc_count)
    );

    // Regime value k
    // regime_msb=1 => k = lbc_count - 1 (positive regime)
    // regime_msb=0 => k = -lbc_count    (negative regime, stored as 2s comp)
    assign regime = regime_msb ? (lbc_count - 4'd1) : (~lbc_count + 4'd1);

    // -------------------------------------------------------------------------
    // Shift remainder to extract exponent and mantissa
    //   After sign (1 bit) + regime (lbc_count+1 bits), remaining bits are:
    //   [exponent(2 bits) | mantissa bits]
    // -------------------------------------------------------------------------
    wire [3:0] shift_amt;
    assign shift_amt = lbc_count + 4'd2;  // sign(1) + regime bits + terminator

    wire [13:0] shifted;
    wire [13:0] mag_body;
    assign mag_body = mag[13:0];

    // MUX-based barrel shift for exponent/mantissa extraction
    MUX14 mux_inst (
        .in     (mag_body),
        .sel    (shift_amt),
        .out    (shifted)
    );

    // -------------------------------------------------------------------------
    // Exponent field (es = 2 bits)
    // -------------------------------------------------------------------------
    assign exp = shifted[13:12];

    // -------------------------------------------------------------------------
    // Mantissa / fraction field (11 bits)
    // -------------------------------------------------------------------------
    assign mantissa = shifted[11:1];

    // -------------------------------------------------------------------------
    // Check flag: asserted when the decoded fields are valid (not special case)
    // -------------------------------------------------------------------------
    assign chck = ~ss;

    // -------------------------------------------------------------------------
    // Subtractor carry-in: used by the subtractor sub-block for alignment
    // -------------------------------------------------------------------------
    assign saddcin = regime_msb;

endmodule
