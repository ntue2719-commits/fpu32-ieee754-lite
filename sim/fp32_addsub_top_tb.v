`timescale 1ns/1ps

module fp32_addsub_top_tb;

    reg  [31:0] a, b;
    wire        result_sign;
    wire [7:0]  result_exponent;
    wire [22:0] result_mantissa;

    fp32_addsub_top uut (
        .a(a), .b(b),
        .result_sign(result_sign),
        .result_exponent(result_exponent),
        .result_mantissa(result_mantissa)
    );

    task show_result(input [255:0] label);
        begin
            #10;
            $display("---- %0s ----", label);
            $display("  sign=%b  exponent=%0d (field)  mantissa=%b",
                       result_sign, result_exponent, result_mantissa);
            $display("  full bits = %b_%b_%b", result_sign, result_exponent, result_mantissa);
        end
    endtask

    initial begin
        // Test 1: 2.5 + 1.0 = 3.5
        // 2.5 = 0x40200000 | 1.0 = 0x3F800000 | ky vong: 3.5 = 0x40600000
        a = 32'h40200000; b = 32'h3F800000;
        show_result("Test1: 2.5 + 1.0 (ky vong = 3.5 = 0x40600000)");

        // Test 2: 2.5 - 1.0 = 1.5
        // 2.5 = 0x40200000 | -1.0 = 0xBF800000 | ky vong: 1.5 = 0x3FC00000
        a = 32'h40200000; b = 32'hBF800000;
        show_result("Test2: 2.5 - 1.0 (ky vong = 1.5 = 0x3FC00000)");

        // Test 3: 1.5 + 1.5 = 3.0 (truong hop CARRY khi cong)
        // 1.5 = 0x3FC00000 | ky vong: 3.0 = 0x40400000
        a = 32'h3FC00000; b = 32'h3FC00000;
        show_result("Test3: 1.5 + 1.5 (ky vong = 3.0 = 0x40400000, co carry)");

        // Test 4: Cancellation - (1.0 + 2^-23) - 1.0 = 2^-23 (LZD phai = 23)
        // A = 0x3F800001 (1 ULP tren 1.0) | -B = -1.0 = 0xBF800000 (dao bit dau de TRU)
        // ky vong: 2^-23 = 0x34000000
        a = 32'h3F800001; b = 32'hBF800000;
        show_result("Test4: cancellation (1.0+2^-23) - 1.0 (ky vong = 2^-23 = 0x34000000)");

        // Test 5: B lon hon A, khac dau -> ket qua am
        // 1.0 - 2.5 = -1.5 -> A=1.0=0x3F800000, -B=-2.5=0xC0200000 (dao bit dau)
        // ky vong: sign=1, exponent/mantissa giong 1.5 (0x3FC00000)
        a = 32'h3F800000; b = 32'hC0200000;
        show_result("Test5: 1.0 - 2.5 (ky vong = -1.5, sign=1, |1.5|=0x3FC00000)");

        $finish;
    end

endmodule
