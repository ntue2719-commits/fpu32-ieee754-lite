module fp_add_sub_top_2(
    input clk,
    input rst_n,

    input [31:0] A,
    input [31:0] B,
    input op,

    output reg [31:0] result
);



// Stage 1 : Special case detection
wire special_valid;
wire [31:0] special_result;

fp_special_case_add_sub u_special(
    .A(A),
    .B(B),
    .op(op),
    .special_valid(special_valid),
    .special_result(special_result)
);

wire [31:0] B_internal;
assign B_internal = (op) ? {~B[31],B[30:0]} : B;

//wire internal in fp_align
wire A_sign;
wire B_sign;

wire [7:0] exponent;

wire [23:0] A_mantissa_ext;
wire [23:0] B_mantissa_shifted;

fp_align u_align(
    .A(A),
    .B(B_internal),

    .A_sign(A_sign),
    .B_sign(B_sign),

    .exponent(exponent),

    .A_mantissa_ext(A_mantissa_ext),
    .B_mantissa_shifted(B_mantissa_shifted)
);


// Pipeline Register 1
reg        r1_special_valid;
reg [31:0] r1_special_result;

reg        r1_A_sign;
reg        r1_B_sign;

reg [7:0]  r1_exponent;

reg [23:0] r1_A_mantissa;
reg [23:0] r1_B_mantissa;

always @(posedge clk or negedge rst_n) begin

    if(!rst_n) begin
        r1_special_valid  <= 1'b0;
        r1_special_result <= 32'd0;

        r1_A_sign <= 1'b0;
        r1_B_sign <= 1'b0;

        r1_exponent <= 8'd0;

        r1_A_mantissa <= 24'd0;
        r1_B_mantissa <= 24'd0;

    end

    else begin
        r1_special_valid  <= special_valid;
        r1_special_result <= special_result;

        r1_A_sign <= A_sign;
        r1_B_sign <= B_sign;

        r1_exponent <= exponent;

        r1_A_mantissa <= A_mantissa_ext;
        r1_B_mantissa <= B_mantissa_shifted;

    end

end


// Stage 2 : Add/Sub + LZD + Normalize


// Add/Sub Core
wire [24:0] sum_mantissa;

fp_add_sub_core u_add_sub(
    .A_sign(r1_A_sign),
    .B_sign(r1_B_sign),
    .A_mantissa(r1_A_mantissa),
    .B_mantissa(r1_B_mantissa),
    .sum_mantissa(sum_mantissa)
);


// Leading Zero Detector
wire [4:0] count_zero;

fp_lzd u_lzd(
    .mantissa(sum_mantissa[23:0]),
    .count_zero(count_zero)
);


// Normalize
wire [7:0] exponent_norm;
wire [22:0] mantissa_norm;

fp_normalize_add_sub u_normalize(
    .mantissa(sum_mantissa),
    .exponent(r1_exponent),
    .shift_left(count_zero),

    .exponent_norm(exponent_norm),
    .mantissa_norm(mantissa_norm)
);

wire result_sign;

assign result_sign = (sum_mantissa == 25'd0) ? 1'b0 : r1_A_sign;

// Pipeline Register 2
reg        r2_special_valid;
reg [31:0] r2_special_result;

reg [7:0]  r2_exponent;
reg [22:0] r2_mantissa;
reg        r2_sign;

always @(posedge clk or negedge rst_n) begin

    if(!rst_n) begin
        r2_special_valid  <= 1'b0;
        r2_special_result <= 32'd0;

        r2_exponent <= 8'd0;
        r2_mantissa <= 23'd0;
        r2_sign <= 1'b0;

    end
    else begin
        r2_special_valid  <= r1_special_valid;
        r2_special_result <= r1_special_result;

        r2_exponent <= exponent_norm;
        r2_mantissa <= mantissa_norm;
        r2_sign <= result_sign;

    end

end

// Stage 3 : Round + Pack
wire [7:0] exponent_out;
wire [22:0] mantissa_out;

fp_round_trunc u_round(

    .exponent_in(r2_exponent),
    .mantissa_in(r2_mantissa),

    .exponent_out(exponent_out),
    .mantissa_out(mantissa_out)

);

wire [31:0] result_pack;

fp_pack u_pack(

    .sign(r2_sign),
    .exponent(exponent_out),
    .fraction(mantissa_out),

    .result(result_pack)

);

always @(posedge clk or negedge rst_n) begin

    if(!rst_n)

        result <= 32'd0;

    else begin

        if(r2_special_valid)

            result <= r2_special_result;

        else

            result <= result_pack;

    end

end
endmodule