module fp_multiplier_2_stage_pipeline(
    input clk,
    input rst_n,

    input [31:0] A,
    input [31:0] B,

    output reg [31:0] result
);

    //==========================================================================
    // Unpack
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
    // Stage 1 Logic
    //==========================================================================

    wire sign_out;

    assign sign_out = sign_A ^ sign_B;

    wire signed [9:0] exponent_product;

    fp_mul_exp exp_mul_inst(
        .exponent_A(exponent_A),
        .exponent_B(exponent_B),
        .exponent_product(exponent_product)
    );

    wire [47:0] mantissa_product;

    fp_mul_mantissa mantissa_mul_inst(
        .fraction_A(fraction_A),
        .fraction_B(fraction_B),
        .mantissa_product(mantissa_product)
    );

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
    // PIPELINE REGISTER STAGE 1
    //==========================================================================

    reg sign_r1;

    reg signed [9:0] exponent_r1;

    reg [47:0] mantissa_r1;

    reg A_zero_r1;
    reg B_zero_r1;

    reg A_inf_r1;
    reg B_inf_r1;

    reg A_nan_r1;
    reg B_nan_r1;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            sign_r1     <= 1'b0;
            exponent_r1 <= 10'sd0;
            mantissa_r1 <= 48'd0;

            A_zero_r1 <= 1'b0;
            B_zero_r1 <= 1'b0;

            A_inf_r1 <= 1'b0;
            B_inf_r1 <= 1'b0;

            A_nan_r1 <= 1'b0;
            B_nan_r1 <= 1'b0;
        end

        else begin
            sign_r1     <= sign_out;
            exponent_r1 <= exponent_product;
            mantissa_r1 <= mantissa_product;

            A_zero_r1 <= A_zero;
            B_zero_r1 <= B_zero;

            A_inf_r1 <= A_inf;
            B_inf_r1 <= B_inf;

            A_nan_r1 <= A_nan;
            B_nan_r1 <= B_nan;
        end
    end

    //==========================================================================
    // Stage 2 Logic
    //==========================================================================

    wire [22:0] fraction_norm;
    wire [7:0] exponent_norm;

    wire overflow;
    wire underflow;

    fp_normalize_mul normalize_inst(
        .mantissa_product(mantissa_r1),
        .exponent_product(exponent_r1),

        .fraction_out(fraction_norm),
        .exponent_out(exponent_norm),

        .overflow(overflow),
        .underflow(underflow)
    );

    wire [22:0] fraction_round;
    wire [7:0] exponent_round;

    fp_round_trunc round_inst(
        .exponent_in(exponent_norm),
        .mantissa_in(fraction_norm),

        .exponent_out(exponent_round),
        .mantissa_out(fraction_round)
    );

    wire [31:0] normal_result;

    fp_pack pack_inst(
        .sign(sign_r1),
        .exponent(exponent_round),
        .fraction(fraction_round),

        .result(normal_result)
    );

    //==========================================================================
    // Output Register
    //==========================================================================

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            result <= 32'd0;

        else begin
            if (A_nan_r1 || B_nan_r1)
                result <= 32'h7FC00000;

            else if ((A_inf_r1 && B_zero_r1) || (B_inf_r1 && A_zero_r1))
                result <= 32'h7FC00000;

            else if (A_inf_r1 || B_inf_r1)
                result <= {sign_r1, 8'hFF, 23'd0};

            else if (A_zero_r1 || B_zero_r1)
                result <= {sign_r1, 8'd0, 23'd0};

            else
                result <= normal_result;
        end
    end
    
endmodule