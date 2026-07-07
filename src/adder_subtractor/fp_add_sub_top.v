module fp_add_sub_top(
    input [31:0] A,
    input [31:0] B,
    input op,
    output reg [31:0] result
);
    //wire internal in fp_special_add_sub
    wire special_valid;
    wire [31:0] special_result;
    //check special case
    fp_special_case_add_sub inst (
        .A(A), 
        .B(B), 
        .op(op), 
        .special_valid(special_valid), 
        .special_result(special_result)        
    );
   

    wire [31:0] B_internal;
    assign B_internal = (op) ? {~B[31], B[30:0]} : B;

    //Wire internal in fp_align
    wire A_sign;
    wire B_sign;
    wire [7:0] exponent;
    wire [23:0] A_mantissa_ext;
    wire [23:0] B_mantissa_shifted;

    fp_align u_align (
        .A(A), 
        .B(B_internal), 
        .A_sign(A_sign), 
        .B_sign(B_sign), 
        .exponent(exponent), 
        .A_mantissa_ext(A_mantissa_ext),
        .B_mantissa_shifted(B_mantissa_shifted)                   
                
    );

    //Wire internal in fp_add_sub_core
    wire [24:0] sum_mantissa;

    fp_add_sub_core u_add_sub (
        .A_sign(A_sign),
        .B_sign(B_sign),
        .A_mantissa(A_mantissa_ext),
        .B_mantissa(B_mantissa_shifted),
        .sum_mantissa(sum_mantissa)        
    );

    //wire internal in fp_lzd
    wire [4:0] count_zero;
    wire [23:0] mantissa = sum_mantissa[23:0];

    fp_lzd u_lzd (
        .mantissa(mantissa), 
        .count_zero(count_zero)
    );

    //wire internal in fp_normalize_add_sub
    wire [7:0] exponent_norm;
    wire [22:0] mantissa_norm;

    fp_normalize_add_sub u_normalize (
        .mantissa(sum_mantissa),
        .exponent(exponent),
        .shift_left(count_zero),
        .exponent_norm(exponent_norm),
        .mantissa_norm(mantissa_norm)
    );

    //internal wire in fp_round_trunc
    wire [7:0] exponent_out;
    wire [22:0] mantissa_out;

    fp_round_trunc u_round (
        .exponent_in(exponent_norm),
        .mantissa_in(mantissa_norm),
        .exponent_out(exponent_out),
        .mantissa_out(mantissa_out)
    );

    //wire internal in fp_pack
    wire result_sign;
    //Sum_mantissa = 0, choose sign = +0;
    assign result_sign = (sum_mantissa == 25'd0) ? 1'b0 : A_sign;
    wire [31:0] result_pack;

    fp_pack u_pack (
        .sign(result_sign),
        .exponent(exponent_out),
        .fraction(mantissa_out),
        .result(result_pack)
    );

    always @ (*) begin
        if(special_valid) begin
            result = special_result;
        end
        else
            result = result_pack;
    end


endmodule

