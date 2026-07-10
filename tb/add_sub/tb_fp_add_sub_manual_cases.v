//==============================================================================
// tb_fp_add_sub_manual_cases.v
//
// PURPOSE:
// This is NOT a self-checking testbench (no automatic pass/fail).
// This is the SECOND verification layer, independent of the Python golden model (gen_vectors.py).
// It allows readers/reviewers to "see with their own eyes" each characteristic case
// and manually compare the result with the expected value to answer the question:
// "How do we know the Python golden model is correct?"
//
// HOW TO USE:
// - Run simulation and observe console output ($display) or waveform (.vcd)
// - For each case, read the "EXPECT:" comment and manually compare with the GOT result
// - There are NO assertions/self-checks in this file
//==============================================================================
`timescale 1ns/1ps

module tb_fp_add_sub_manual_cases;
    reg [31:0] A, B;
    reg op;
    wire [31:0] result;

    // ---- Instantiate DUT (change module name to match your top-level design) ----
    fp_add_sub_top dut (
        .A      (A),
        .B      (B),
        .op     (op),
        .result (result)
    );

    // ---- Dump waveform ----
    // Do NOT use $dumpfile/$dumpvars here because XSIM (Vivado) does not handle it reliably.
    // To view waveform, use one of the following methods:
    // (1) Vivado GUI: Run Behavioral Simulation, add signals to waveform, then run "run -all"
    // (2) Batch/Tcl: Use commands open_vcd / log_vcd / close_vcd (see run_sim.tcl file)

    // ---- Print whenever inputs change (no comparison/assertion) ----
    always @(A or B or op) begin
        #5; // wait for combinational logic to stabilize before printing
        $display("[%0t] A=%08h B=%08h op=%0b -> result=%08h",
                  $time, A, B, op, result);
    end

    integer i;
    initial begin
        $display("========================================================");
        $display(" MANUAL CHARACTERISTIC CASES - fp_add_sub_top");
        $display(" (Read each line and compare with EXPECT column in comments)");
        $display("========================================================");

        // ------------------------------------------------------------------
        // CASE 1: Exact cancellation A - A = +0
        // A = 0x4C6C0311 (normal positive number)
        // op = 1 (subtract) → A - A
        // EXPECT: result = 0x00000000 (+0, must NOT be -0)
        // ------------------------------------------------------------------
        A = 32'h4C6C0311; B = 32'h4C6C0311; op = 1'b1; #10;

        // ------------------------------------------------------------------
        // CASE 2: Near cancellation (mantissas differ by a few bits, same exponent)
        // Purpose: Check LZD (Leading Zero Detector) works correctly when subtraction
        // results in many leading zeros → requires large left shift for normalization.
        // A = 0x40000010, B = 0x4000000F (same exponent = 0x80,
        // mantissas differ by 1 at the LSB)
        // EXPECT: result has very small mantissa, exponent much smaller than
        // original A/B (due to heavy normalization shift)
        // ------------------------------------------------------------------
        A = 32'h40000010; B = 32'h4000000F; op = 1'b1; #10;

        // ------------------------------------------------------------------
        // CASE 3: Absorption - exponent difference >= 24
        // A exponent = 0x5D (93), B exponent = 0x83 (131) → difference = 38 >= 24
        // EXPECT: result = the operand with the larger exponent (B), unchanged
        // (smaller operand's mantissa is completely shifted out)
        // ------------------------------------------------------------------
        A = 32'hAEB82567; B = 32'h41FE570D; op = 1'b0; #10;

        // ------------------------------------------------------------------
        // CASE 4: Carry-out after addition (mantissa overflow beyond bit 24)
        // Two numbers with near-max mantissas, same sign and exponent.
        // Addition causes overflow → must right-shift 1 bit and increment exponent.
        // A = 0x7F7FFFFF, B = 0x7F7FFFFF
        // op = 0 (add)
        // EXPECT: result exponent = exponent(A) + 1 = 0xFF
        // ------------------------------------------------------------------
        A = 32'h7F7FFFFF; B = 32'h7F7FFFFF; op = 1'b0; #10;

        // ------------------------------------------------------------------
        // CASE 5: NaN propagation
        // A = normal number, B = NaN (exponent=0xFF, mantissa != 0)
        // op = 0 (add)
        // EXPECT: result = Quiet NaN = 0x7FC00000
        // (Any operation involving NaN should return QNaN)
        // ------------------------------------------------------------------
        A = 32'h3F800000; B = 32'h7FC00001; op = 1'b0; #10;

        // ------------------------------------------------------------------
        // CASE 6: Inf - Inf (same sign) → QNaN
        // A = +Inf, B = +Inf, op = 1 (subtract)
        // EXPECT: result = QNaN = 0x7FC00000
        // (Mathematically indeterminate)
        // ------------------------------------------------------------------
        A = 32'h7F800000; B = 32'h7F800000; op = 1'b1; #10;

        // ------------------------------------------------------------------
        // CASE 7: Inf + Inf (same sign) → still Inf, NOT NaN
        // A = +Inf, B = +Inf, op = 0 (add)
        // EXPECT: result = +Inf = 0x7F800000
        // ------------------------------------------------------------------
        A = 32'h7F800000; B = 32'h7F800000; op = 1'b0; #10;

        // ------------------------------------------------------------------
        // CASE 8: +0 + (-0) → +0
        // EXPECT: result = 0x00000000
        // ------------------------------------------------------------------
        A = 32'h00000000; B = 32'h80000000; op = 1'b0; #10;

        // ------------------------------------------------------------------
        // CASE 9: 0 - positive number → negate the number
        // A = +0, B = 0x3F800000 (= 1.0), op = 1 (subtract)
        // EXPECT: result = 0xBF800000 (= -1.0)
        // ------------------------------------------------------------------
        A = 32'h00000000; B = 32'h3F800000; op = 1'b1; #10;

        // ------------------------------------------------------------------
        // CASE 10: Denormal + Denormal (both have hidden bit = 0)
        // A = 0x00000001 (smallest positive denormal)
        // B = 0x00000002 (twice A)
        // op = 0 (add)
        // EXPECT: result = 0x00000003 (direct mantissa addition because exponent=0)
        // ------------------------------------------------------------------
        A = 32'h00000001; B = 32'h00000002; op = 1'b0; #10;

        $display("========================================================");
        $display(" END OF CHARACTERISTIC CASES.");
        $display(" Review console output or .vcd waveform to compare");
        $display(" each line with the EXPECT comments above.");
        $display("========================================================");
        #20;
        $finish;
    end
endmodule