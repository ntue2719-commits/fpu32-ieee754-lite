module fp_multiplier_nonpipeline(
    input  [31:0] A,
    input  [31:0] B,

    output reg [31:0] result
);

    //==========================================================================
    // Unpack IEEE754
    //==========================================================================

    wire sign_A;
    wire sign_B;

    wire [7:0] exponent_A;
    wire [7:0] exponent_B;

    wire [22:0] fraction_A;
    wire [22:0] fraction_B;

    assign sign_A     = A[31];
    assign exponent_A = A[30:23];
    assign fraction_A = A[22:0];

    assign sign_B     = B[31];
    assign exponent_B = B[30:23];
    assign fraction_B = B[22:0];

    //==========================================================================
    // Special Case
    //==========================================================================

    wire A_zero;
    wire B_zero;

    wire A_inf;
    wire B_inf;

    wire A_nan;
    wire B_nan;

    fp_special_case_mul special_case_inst(
        .exponent_A(exponent_A),
        .fraction_A(fraction_A),

        .exponent_B(exponent_B),
        .fraction_B(fraction_B),

        .A_zero(A_zero),
        .B_zero(B_zero),

        .A_inf(A_inf),
        .B_inf(B_inf),

        .A_nan(A_nan),
        .B_nan(B_nan)
    );

    //==========================================================================
    // Sign
    //==========================================================================

    wire sign_out;

    assign sign_out = sign_A ^ sign_B;

    //==========================================================================
    // Exponent Multiply
    //==========================================================================

    wire signed [9:0] exponent_product;

    fp_mul_exp exp_mul_inst(
        .exponent_A(exponent_A),
        .exponent_B(exponent_B),

        .exponent_product(exponent_product)
    );

    //==========================================================================
    // Mantissa Multiply
    //==========================================================================

    wire [47:0] mantissa_product;

    fp_mul_mantissa mantissa_mul_inst(
        .fraction_A(fraction_A),
        .fraction_B(fraction_B),

        .mantissa_product(mantissa_product)
    );

    //==========================================================================
    // Normalize + Overflow/Underflow
    //==========================================================================

    wire [22:0] fraction_norm;
    wire [7:0]  exponent_norm;

    wire overflow;
    wire underflow;

    fp_normalize_mul normalize_inst(
        .mantissa_product(mantissa_product),
        .exponent_product(exponent_product),

        .fraction_out(fraction_norm),
        .exponent_out(exponent_norm),

        .overflow(overflow),
        .underflow(underflow)
    );

    //==========================================================================
    // Round (Truncation)
    //==========================================================================

    wire [7:0] exponent_round;
    wire [22:0] fraction_round;

    fp_round_trunc round_inst(
        .exponent_in(exponent_norm),
        .mantissa_in(fraction_norm),

        .exponent_out(exponent_round),
        .mantissa_out(fraction_round)
    );

    //==========================================================================
    // Pack
    //==========================================================================

    wire [31:0] normal_result;

    fp_pack pack_inst(
        .sign(sign_out),
        .exponent(exponent_round),
        .fraction(fraction_round),

        .result(normal_result)
    );

    //==========================================================================
    // Final Result Selection
    //==========================================================================

    always @(*) begin
        // NaN input
        if (A_nan || B_nan)
            result = 32'h7FC00000;

        // Infinity × Zero = NaN
        else if ((A_inf && B_zero) || (B_inf && A_zero))
            result = 32'h7FC00000;

        // Infinity
        else if (A_inf || B_inf)
            result = {sign_out, 8'hFF, 23'd0};

        // Zero
        else if (A_zero || B_zero)
            result = {sign_out, 8'd0, 23'd0};

        // Normal result
        else
            result = normal_result;
    end

endmodule