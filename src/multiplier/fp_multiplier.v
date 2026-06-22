module fp_multiplier(
    input [31:0] A,
    input [31:0] B,

    output [31:0] result
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


    // Unpack A
    unpack unpack_A(
        .in(A),

        .sign(sign_A),
        .exponent(exponent_A),
        .fraction(fraction_A)
    );


    // Unpack B
    unpack unpack_B(
        .in(B),

        .sign(sign_B),
        .exponent(exponent_B),
        .fraction(fraction_B)
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


    // Pack
    pack pack_result(
        .sign(sign_out),
        .exponent(exponent_norm),
        .fraction(fraction_norm),

        .result(result)
    );
endmodule