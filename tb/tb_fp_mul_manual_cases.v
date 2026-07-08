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

task run_case;

input [31:0] a_in;
input [31:0] b_in;

begin
    A = a_in;
    B = b_in;

    #10;

    $display("-----------------------------------");
    $display("A      = %h",A);
    $display("B      = %h",B);
    $display("RESULT = %h",result);
end

endtask

initial begin
    $dumpfile("fp_mul_manual.vcd");
    $dumpvars(0,tb_fp_mul_manual_cases);

    $display("===== FP32 MULTIPLIER MANUAL TEST =====");

    // 1.0 * 1.0
    run_case(32'h3F800000,32'h3F800000);

    // 2.0 * 2.0
    run_case(32'h40000000,32'h40000000);

    // 3.5 * 2.0
    run_case(32'h40600000,32'h40000000);

    // -2.0 * 4.0
    run_case(32'hC0000000,32'h40800000);

    // 0 * 5
    run_case(32'h00000000,32'h40A00000);

    // INF * 2
    run_case(32'h7F800000,32'h40000000);

    // INF * 0
    run_case(32'h7F800000,32'h00000000);

    // NaN * 3
    run_case(32'h7FC00000,32'h40400000);

    // Max Float * Max Float
    run_case(32'h7F7FFFFF,32'h7F7FFFFF);

    // Min Normal * Min Normal
    run_case(32'h00800000,32'h00800000);

    #20;
    $finish;
end

endmodule