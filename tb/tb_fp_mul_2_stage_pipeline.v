`timescale 1ns/1ps

module tb_fp_mul_2_stage_pipeline;

reg clk;
reg rst_n;

reg [31:0] A;
reg [31:0] B;

wire [31:0] result;

fp_multiplier_2_stage_pipeline dut(
    .clk(clk),
    .rst_n(rst_n),
    .A(A),
    .B(B),
    .result(result)
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    rst_n = 0;

    $dumpfile("fp_mul_pipe2.vcd");
    $dumpvars(0,tb_fp_mul_pipe2);

    #20;
    rst_n = 1;

    $display("===== PIPELINE 2 STAGE =====");

    A = 32'h3F800000;
    B = 32'h3F800000;
    #30;
    $display("1.0 * 1.0 = %h",result);

    A = 32'h40000000;
    B = 32'h40000000;
    #30;
    $display("2.0 * 2.0 = %h",result);

    A = 32'h40600000;
    B = 32'h40000000;
    #30;
    $display("3.5 * 2.0 = %h",result);

    A = 32'hC0000000;
    B = 32'h40800000;
    #30;
    $display("-2.0 * 4.0 = %h",result);

    #50;
    $finish;
end

endmodule