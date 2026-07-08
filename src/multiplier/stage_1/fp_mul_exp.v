module fp_mul_exp(
    input [7:0] exponent_A,
    input [7:0] exponent_B,

    output signed [9:0] exponent_product
);

assign exponent_product = $signed({1'b0, exponent_A}) + $signed({1'b0, exponent_B}) - 10'sd127;

endmodule