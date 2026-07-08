`timescale 1ns/1ps

module tb_fp_mul_nonpipeline;

reg [31:0] A;
reg [31:0] B;

wire [31:0] result;

fp_multiplier_nonpipeline dut(
    .A(A),
    .B(B),
    .result(result)
);

initial begin
    $dumpfile("fp_mul_nonpipeline.vcd");
    $dumpvars(0,tb_fp_mul_nonpipeline);

    $display("===== NON PIPELINE MULTIPLIER =====");

    A = 32'h3F800000; //1.0
    B = 32'h3F800000; //1.0
    #10;
    $display("1.0 * 1.0 = %h",result);

    A = 32'h40000000; //2.0
    B = 32'h40000000; //2.0
    #10;
    $display("2.0 * 2.0 = %h",result);

    A = 32'h40600000; //3.5
    B = 32'h40000000; //2.0
    #10;
    $display("3.5 * 2.0 = %h",result);

    A = 32'hC0000000; //-2.0
    B = 32'h40800000; //4.0
    #10;
    $display("-2.0 * 4.0 = %h",result);

    A = 32'h00000000; //0
    B = 32'h40A00000; //5
    #10;
    $display("0 * 5 = %h",result);

    #20;
    $finish;
end

endmodule