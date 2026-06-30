`timescale 1ns/1ps

module fp32_align_tb;

    reg  [31:0] a, b;
    wire        sign_a, sign_b;
    wire [7:0]  exp_common, exp_diff;
    wire        a_is_larger;
    wire [23:0] mant_a_aligned, mant_b_aligned;

    fp32_align uut (
        .a(a), .b(b),
        .sign_a(sign_a), .sign_b(sign_b),
        .exp_common(exp_common), .exp_diff(exp_diff),
        .a_is_larger(a_is_larger),
        .mant_a_aligned(mant_a_aligned),
        .mant_b_aligned(mant_b_aligned)
    );

    task show_result(input [127:0] label);
        begin
            #10;
            $display("---- %0s ----", label);
            $display("  a_is_larger = %b   exp_diff = %0d   exp_common = %0d", a_is_larger, exp_diff, exp_common);
            $display("  mant_a_aligned = %b", mant_a_aligned);
            $display("  mant_b_aligned = %b", mant_b_aligned);
        end
    endtask

    initial begin
        // Test 1: A = 2.5  (0x40200000), B = 1.0 (0x3F800000) -> A lon hon, lech 1 exponent
        a = 32'h40200000; b = 32'h3F800000;
        show_result("Test1: A=2.5, B=1.0");

        // Test 2: A = 1.0, B = 1.0 -> exponent bang nhau, exp_diff = 0
        a = 32'h3F800000; b = 32'h3F800000;
        show_result("Test2: A=1.0, B=1.0");

        // Test 3: A = 0.5 (0x3F000000), B = 4.0 (0x40800000) -> B lon hon
        a = 32'h3F000000; b = 32'h40800000;
        show_result("Test3: A=0.5, B=4.0");

        // Test 4: A = 8.0 (0x41000000), B = 0.0009765625 = 2^-10 (0x3A800000) -> lech exponent lon (>24)
        a = 32'h41000000; b = 32'h3A800000;
        show_result("Test4: A=8.0, B=2^-10 (lech exponent lon)");

        $finish;
    end

endmodule
