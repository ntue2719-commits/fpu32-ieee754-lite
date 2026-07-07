//==============================================================================
// Module : align
// Function:
//   - Compare operand magnitudes
//   - Swap operands
//   - Restore hidden bits
//   - Align mantissas
//   - Align mantissas based on exponent difference
//==============================================================================

module fp_align (
    input  [31:0] A,
    input  [31:0] B,

    output        A_sign,
    output        B_sign,
    output [7:0]  exponent,
    output [23:0] A_mantissa_ext,
    output [23:0] B_mantissa_shifted
);

// Compare the magnitudes of two operands and swap them if necessary
// Ensure that |A| >= |B| for exponent alignment
wire comp;

fp_compare inst1 (
    .A({1'b0, A[30:0]}),
    .B({1'b0, B[30:0]}),
    .result(comp)
);

wire [31:0] max_val = comp ? A : B;
wire [31:0] min_val = comp ? B : A;

// Extract sign and use the larger exponent as the base exponent
assign A_sign = max_val[31];
assign B_sign = min_val[31];
assign exponent = max_val[30:23];

// Restore the hidden bit
// Normalized number  : hidden bit = 1
// Denormalized number: hidden bit = 0
