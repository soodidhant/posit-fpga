// =============================================================================
// Testbench : Decoder_tb
// Tests the 16-bit posit Decoder module with known values,
// special cases (zero, NaR), and a sweep of inputs.
// =============================================================================

`timescale 1ns/1ps

module Decoder_tb;

    reg  [15:0] posit_in;
    wire        sign;
    wire [3:0]  regime;
    wire [1:0]  exp;
    wire [10:0] mantissa;
    wire        ss;
    wire        chck;
    wire        saddcin;

    // DUT
    Decoder uut (
        .posit_in (posit_in),
        .sign     (sign),
        .regime   (regime),
        .exp      (exp),
        .mantissa (mantissa),
        .ss       (ss),
        .chck     (chck),
        .saddcin  (saddcin)
    );

    task apply_and_display;
        input [15:0] val;
        input [63:0] label;
        begin
            posit_in = val;
            #10;
            $display("%-20s | posit_in=%016b | sign=%b regime=%04b exp=%02b mantissa=%011b ss=%b chck=%b",
                     label, posit_in, sign, regime, exp, mantissa, ss, chck);
        end
    endtask

    initial begin
        $display("=== Posit Decoder Testbench ===");
        $display("%-20s | %-16s | sign | regime | exp | mantissa    | ss | chck",
                 "Label", "posit_in");

        // Special cases
        apply_and_display(16'h0000, "Zero");
        apply_and_display(16'h8000, "NaR");

        // Positive posit values
        apply_and_display(16'h4000, "+1.0");          // k=0, exp=0, frac=0
        apply_and_display(16'h6000, "+2.0");          // k=1
        apply_and_display(16'h7000, "+4.0");
        apply_and_display(16'h3800, "+0.5");
        apply_and_display(16'h2000, "+0.25");

        // Negative values
        apply_and_display(16'hC000, "-1.0");
        apply_and_display(16'hA000, "-2.0");

        // The example from the report: 19346.673
        // 19346 ~ 2^14.24, posit encoding for large values
        apply_and_display(16'h7C00, "large+");
        apply_and_display(16'hFA00, "large-");

        // Sweep lower bits
        repeat (16) begin
            posit_in = $random;
            #10;
            $display("Random       | posit_in=%016b | sign=%b regime=%04b exp=%02b mantissa=%011b ss=%b",
                     posit_in, sign, regime, exp, mantissa, ss);
        end

        $display("=== Testbench Complete ===");
        $finish;
    end

    // VCD dump for waveform inspection
    initial begin
        $dumpfile("sim/Decoder_tb.vcd");
        $dumpvars(0, Decoder_tb);
    end

endmodule
