// =============================================================================
// Module  : Encoder
// Project : Design and FPGA Implementation of Posit Encoder and Decoder
// Authors : Abhinav Nagpal (2210110111), Idhant Sood (2210110303)
// Advisor : Dr. Rakesh Palisetty, Shiv Nadar Institution of Eminence
// Date    : November 2025
//
// Description:
//   16-bit posit encoder. Reconstructs a 16-bit posit binary number from
//   its decomposed fields: sign, regime (k), exponent (es=2), and mantissa.
//   Complements the Decoder to enable round-trip encode-decode validation.
//
//   Posit format:  [sign | regime_run | exponent(2) | fraction]
//   Special cases: zero => 16'h0000, NaR => 16'h8000
// =============================================================================

module Encoder (
    input  wire        sign,
    input  wire [3:0]  regime,     // k value (signed, 2s complement)
    input  wire [1:0]  exp,
    input  wire [10:0] mantissa,
    input  wire        ss,         // special case flag
    output reg  [15:0] posit_out
);

    integer      i;
    reg  [14:0]  body;
    reg  [3:0]   k_mag;
    reg          k_sign;
    reg  [14:0]  regime_bits;
    reg  [3:0]   regime_len;
    reg  [14:0]  shifted_body;

    always @(*) begin
        // -------------------------------------------------------
        // Special cases
        // -------------------------------------------------------
        if (ss) begin
            posit_out = (sign) ? 16'h8000 : 16'h0000;
        end else begin

            // -------------------------------------------------------
            // Determine regime polarity and magnitude
            // k >= 0 : regime = (k+1) ones followed by a zero
            // k <  0 : regime = (-k) zeros followed by a one
            // -------------------------------------------------------
            k_sign = regime[3];          // MSB of 4-bit 2s-comp
            k_mag  = k_sign ? (~regime + 4'd1) : regime;

            // Build regime bit-string (up to 14 bits)
            regime_bits = 15'd0;
            if (!k_sign) begin
                // positive k: (k+1) ones then a 0
                regime_len = k_mag + 4'd2;   // ones + terminator
                for (i = 14; i >= 0; i = i - 1) begin
                    if (i > (13 - k_mag))
                        regime_bits[i] = 1'b1;
                    else if (i == (13 - k_mag))
                        regime_bits[i] = 1'b0;
                end
            end else begin
                // negative k: (-k) zeros then a 1
                regime_len = k_mag + 4'd1;   // zeros + terminator
                for (i = 14; i >= 0; i = i - 1) begin
                    if (i == (14 - k_mag))
                        regime_bits[i] = 1'b1;
                    else if (i > (14 - k_mag))
                        regime_bits[i] = 1'b0;
                end
            end

            // -------------------------------------------------------
            // Pack body: regime | exp | mantissa, right-aligned
            // -------------------------------------------------------
            body = 15'd0;
            body = regime_bits | ({13'b0, exp} << (13 - regime_len)) |
                   ({4'b0, mantissa} >> (regime_len - 2));

            // -------------------------------------------------------
            // Negate body if sign = 1 (2s complement)
            // -------------------------------------------------------
            posit_out[14:0] = sign ? (~body[14:0] + 15'd1) : body[14:0];
            posit_out[15]   = sign;
        end
    end

endmodule
