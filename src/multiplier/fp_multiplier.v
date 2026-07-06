module fp_multiplier(
    input [31:0] A,
    input [31:0] B,

    output reg [31:0] result
);


    // Signals from unpack
    wire sign_A;
    wire sign_B;

    wire [7:0] exponent_A;
    wire [7:0] exponent_B;

    wire [22:0] fraction_A;
    wire [22:0] fraction_B;


    // Intermediate signals
    wire sign_out;

    wire [8:0] exponent_product;

    wire [47:0] mantissa_product;

    wire [22:0] fraction_norm;

    wire [8:0] exponent_norm;


    // Speacial case signals
    wire A_zero;
    wire B_zero;

    wire A_inf;
    wire B_inf;

    wire A_nan;
    wire B_nan;

    wire [7:0] exponent_final;
    wire [22:0] fraction_final;


    // Overflow Underflow signals
    wire overflow;
    wire underflow;

    wire [31:0] normal_result;


    // Unpack
    assign sign_A     = A[31];
    assign exponent_A = A[30:23];
    assign fraction_A = A[22:0];

    assign sign_B     = B[31];
    assign exponent_B = B[30:23];
    assign fraction_B = B[22:0];


    // Speacial case detect
    special_case sc(
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


    // Sign Multiply
    assign sign_out = sign_A ^ sign_B;


    // Exponent Multiply
    exponent_multiply exp_mul(
        .exponent_A(exponent_A),
        .exponent_B(exponent_B),

        .exponent_product(exponent_product)
    );


    // Mantissa Multiply
    mantissa_multiply man_mul(
        .fraction_A(fraction_A),
        .fraction_B(fraction_B),

        .mantissa_product(mantissa_product)
    );


    // Normalize
    normalize norm(
        .mantissa_product(mantissa_product),
        .exponent_product(exponent_product),

        .fraction_out(fraction_norm),
        .exponent_out(exponent_norm)
    );


    // Overflow Underflow handle
    overflow_underflow ouf(
        .exponent_in(exponent_norm),
        .fraction_in(fraction_norm),

        .exponent_out(exponent_final),
        .fraction_out(fraction_final),

        .overflow(overflow),
        .underflow(underflow)
    );


    // Pack
    pack pack_result(
        .sign(sign_out),
        .exponent(exponent_final),
        .fraction(fraction_final),
        .result(normal_result)
    );


    always @(*) begin

    if (A_nan || B_nan)
        result = 32'h7FC00000;

    else if ((A_inf && B_zero) ||
             (B_inf && A_zero))
        result = 32'h7FC00000;

    else if (A_inf || B_inf)
        result = {sign_out, 8'hFF, 23'd0};

    else if (A_zero || B_zero)
        result = {sign_out, 8'd0, 23'd0};

    else
        result = normal_result;

    end

endmodule