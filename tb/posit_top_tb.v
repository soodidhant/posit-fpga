// =============================================================================
// Testbench : posit_top_tb
// Round-trip test: applies 16-bit posit values, decodes them, re-encodes,
// and checks that posit_out == posit_in for all non-special-case values.
// =============================================================================

`timescale 1ns/1ps

module posit_top_tb;

    reg  [15:0] posit_in;
    wire [15:0] posit_out;
    wire        sign;
    wire [3:0]  regime;
    wire [1:0]  exp;
    wire [10:0] mantissa;
    wire        ss, chck, saddcin;

    integer pass_count, fail_count, total;

    posit_top uut (
        .posit_in  (posit_in),
        .posit_out (posit_out),
        .sign      (sign),
        .regime    (regime),
        .exp       (exp),
        .mantissa  (mantissa),
        .ss        (ss),
        .chck      (chck),
        .saddcin   (saddcin)
    );

    initial begin
        pass_count = 0;
        fail_count = 0;
        total      = 0;

        $display("=== Round-Trip Posit Encode-Decode Testbench ===");
        $dumpfile("sim/posit_top_tb.vcd");
        $dumpvars(0, posit_top_tb);

        // Full 16-bit sweep (65536 values)
        for (posit_in = 16'd0; posit_in <= 16'hFFFF; posit_in = posit_in + 1) begin
            #5;
            total = total + 1;
            if (posit_out !== posit_in) begin
                fail_count = fail_count + 1;
                if (fail_count <= 20)   // Print first 20 failures only
                    $display("FAIL: posit_in=%04h  posit_out=%04h  sign=%b regime=%04b exp=%b mant=%011b",
                             posit_in, posit_out, sign, regime, exp, mantissa);
            end else begin
                pass_count = pass_count + 1;
            end
            if (posit_in == 16'hFFFF) begin  // prevent infinite loop
                posit_in = posit_in + 1;
                disable posit_in;
            end
        end

        $display("--- Results ---");
        $display("Total  : %0d", total);
        $display("Pass   : %0d", pass_count);
        $display("Fail   : %0d", fail_count);
        if (fail_count == 0)
            $display("RESULT : ALL PASS - Round-trip encode/decode verified.");
        else
            $display("RESULT : %0d FAILURES detected.", fail_count);

        $finish;
    end

endmodule
