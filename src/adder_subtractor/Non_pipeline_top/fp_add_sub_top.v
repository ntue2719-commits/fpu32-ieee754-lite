module fp_align (
    input  [31:0] A,
    input  [31:0] B,
    output        A_sign,
    output        B_sign,
    output [7:0]  exponent,
    output [23:0] A_mantissa_ext,
    output [23:0] B_mantissa_shifted
);

    // B? HO?C COMMENT ?O?N KH?I T?O FP_COMPARE C?:
    // wire comp;
    // fp_compare inst1 (
    //     .A({1'b0, A[30:0]}),
    //     .B({1'b0, B[30:0]}),
    //     .result(comp)
    // );
    // wire [31:0] max_val = comp ? A : B;
    // wire [31:0] min_val = comp ? B : A;

    // THAY B?NG LOGIC SO SÁNH EXPONENT TR?C TI?P D??I ?ÂY:
    wire exp_A_greater = (A[30:23] > B[30:23]) || ((A[30:23] == B[30:23]) && (A[22:0] >= B[22:0]));

    wire [31:0] max_val = exp_A_greater ? A : B;
    wire [31:0] min_val = exp_A_greater ? B : A;

    // Các ph?n bên d??i gi? nguyên y h?t code c? c?a b?n
    assign A_sign = max_val[31];
    assign B_sign = min_val[31]; 
    assign exponent = max_val[30:23];

    assign A_mantissa_ext = (max_val[30:23] == 8'd0) ? {1'b0, max_val[22:0]} : {1'b1, max_val[22:0]};
    wire [23:0] min_mantissa = (min_val[30:23] == 8'd0) ? {1'b0, min_val[22:0]} : {1'b1, min_val[22:0]};

    wire [7:0] E_dif = max_val[30:23] - min_val[30:23];
    assign B_mantissa_shifted = (E_dif >= 8'd24) ? 24'd0 : (min_mantissa >> E_dif);

endmodule