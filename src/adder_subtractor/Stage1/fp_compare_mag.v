//==============================================================================
// Module : floating_compare
// Function:
//   Compare two IEEE-754 single-precision floating-point operands.
//   Output is asserted when A >= B.
//==============================================================================

module fp_compare (
    input  [31:0] A,
    input  [31:0] B,
    output reg    result
);

// Detect NaN operands
wire a_is_nan  = (&A[30:23]) && (|A[22:0]);
wire b_is_nan  = (&B[30:23]) && (|B[22:0]);

// Detect signed zeros
wire a_is_zero = (A[30:0] == 31'd0);
wire b_is_zero = (B[30:0] == 31'd0);

// Compare operands
always @(*) begin

    // Default output
    result = 1'b0;

    // NaN: every comparison (except !=) is false
    if (a_is_nan || b_is_nan) begin
        result = 1'b0;
    end

    // +0 and -0 are considered equal
    else if (a_is_zero && b_is_zero) begin
        result = 1'b1;
    end

    // Bitwise identical
    else if (A == B) begin
        result = 1'b1;
    end

    // Different signs
    else if (A[31] != B[31]) begin
        result = ~A[31];
    end

    // Same sign: positive numbers
    else if (A[31] == 1'b0) begin

        if (A[30:23] != B[30:23])
            result = (A[30:23] > B[30:23]);
        else
            result = (A[22:0] > B[22:0]);

    end

    // Same sign: negative numbers
    else begin

        if (A[30:23] != B[30:23])
            result = (A[30:23] < B[30:23]);
        else
            result = (A[22:0] < B[22:0]);

    end

end

endmodule