`timescale 1ns/1ps

module tb_fp_mul_manual_cases;

    reg [31:0] A;
    reg [31:0] B;

    wire [31:0] result;

    fp_multiplier_nonpipeline dut(
        .A(A),
        .B(B),
        .result(result)
    );

    always @(A or B) begin
        #5;
        $display("[%0t] A=%08h B=%08h -> result=%08h",
                 $time,A,B,result);
    end

    initial begin
        $display("====================================");
        $display("MANUAL CHARACTERISTIC CASES");
        $display("====================================");

        // 1.0 * 1.0 = 1.0
        A = 32'h3F800000;
        B = 32'h3F800000;
        #10;

        // 2.0 * 2.0 = 4.0
        A = 32'h40000000;
        B = 32'h40000000;
        #10;

        // 3.5 * 2.0 = 7.0
        A = 32'h40600000;
        B = 32'h40000000;
        #10;

        // -2.0 * 4.0 = -8.0
        A = 32'hC0000000;
        B = 32'h40800000;
        #10;

        // 0 * 5 = 0
        A = 32'h00000000;
        B = 32'h40A00000;
        #10;

        // INF * 2 = INF
        A = 32'h7F800000;
        B = 32'h40000000;
        #10;

        // INF * 0 = NaN
        A = 32'h7F800000;
        B = 32'h00000000;
        #10;

        // NaN * 3 = NaN
        A = 32'h7FC00000;
        B = 32'h40400000;
        #10;

        $finish;
    end

endmodule