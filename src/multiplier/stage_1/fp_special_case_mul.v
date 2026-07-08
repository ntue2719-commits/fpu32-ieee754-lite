module fp_special_case_mul(
    input  [7:0] exponent_A,
    input  [22:0] fraction_A,

    input  [7:0] exponent_B,
    input  [22:0] fraction_B,

    output A_zero,
    output B_zero,

    output A_inf,
    output B_inf,

    output A_nan,
    output B_nan
);

assign A_zero = (exponent_A == 8'd0) && (fraction_A == 23'd0);

assign B_zero = (exponent_B == 8'd0) && (fraction_B == 23'd0);

assign A_inf = (exponent_A == 8'hFF) && (fraction_A == 23'd0);

assign B_inf = (exponent_B == 8'hFF) && (fraction_B == 23'd0);

assign A_nan = (exponent_A == 8'hFF) && (fraction_A != 23'd0);

assign B_nan = (exponent_B == 8'hFF) && (fraction_B != 23'd0);

endmodule