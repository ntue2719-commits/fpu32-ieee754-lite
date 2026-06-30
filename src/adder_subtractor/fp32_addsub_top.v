
// Module : fp32_addsub_top
// Tuan 2 : Ghep noi Align (tuan 1) + AddSub + LZD + Normalize
//          -> bo cong/tru IEEE-754 32-bit hoan chinh (chua pipeline)
//
// Ghi chu: day la phien ban COMBINATIONAL (chua co clock), dung de
//          kiem tra logic dung truoc khi pipeline hoa o tuan 3.
//          Chua xu ly Zero/NaN/Infinity/Denormal va chua co Guard bit
//          (se them o tuan 3).


module fp32_addsub_top (
    input  wire [31:0] a,
    input  wire [31:0] b,

    output wire        result_sign,
    output wire [7:0]  result_exponent,
    output wire [22:0] result_mantissa
);

    //  Stage 1: Align (tuan 1) 
    wire        sign_a, sign_b;
    wire [7:0]  exp_common, exp_diff;
    wire        a_is_larger;
    wire [23:0] mant_a_aligned, mant_b_aligned;

    fp32_align u_align (
        .a(a), .b(b),
        .sign_a(sign_a), .sign_b(sign_b),
        .exp_common(exp_common), .exp_diff(exp_diff),
        .a_is_larger(a_is_larger),
        .mant_a_aligned(mant_a_aligned),
        .mant_b_aligned(mant_b_aligned)
    );

    //  Stage 2: Add/Sub mantissa (tuan 2) 
    wire        op_is_sub;
    wire [24:0] sum_result;
    wire [23:0] diff_result;

    fp32_addsub_mantissa u_addsub (
        .sign_a(sign_a), .sign_b(sign_b),
        .mant_a_aligned(mant_a_aligned),
        .mant_b_aligned(mant_b_aligned),
        .result_sign(result_sign),
        .op_is_sub(op_is_sub),
        .sum_result(sum_result),
        .diff_result(diff_result)
    );

    //  Stage 3: LZD + Normalize (tuan 2) 
    wire [4:0] lzd_count;

    lzd24 u_lzd (
        .in(diff_result),
        .count(lzd_count)
    );

    fp32_normalize u_norm (
        .op_is_sub(op_is_sub),
        .sum_result(sum_result),
        .diff_result(diff_result),
        .lzd_count(lzd_count),
        .exp_common(exp_common),
        .norm_mantissa(result_mantissa),
        .norm_exponent(result_exponent)
    );

endmodule
