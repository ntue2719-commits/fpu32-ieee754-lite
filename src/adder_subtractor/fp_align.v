//==============================================================================
// Module : align
// Function:
//   - Compare operand magnitudes
//   - Swap operands
//   - Restore hidden bits
//   - Align mantissas
//   - Generate Guard, Round and Sticky bits
//==============================================================================

module fp_align (
    input  [31:0] A,
    input  [31:0] B,

    output        A_sign,
    output        B_sign,
    output [8:0]  exponent,
    output [23:0] A_mantissa_ext,
    output [23:0] B_mantissa_shifted,

    // Guard, Round and Sticky bits used for IEEE754 rounding
    output reg guard,
    output reg round,
    output reg sticky
);


// Compare the magnitudes of two operands and swap them if necessary
// Ensure that |A| >= |B| for exponent alignment
wire comp;

floating_compare inst1 (
    .A({1'b0, A[30:0]}),
    .B({1'b0, B[30:0]}),
    .result(comp)
);

wire [31:0] max_val = comp ? A : B;
wire [31:0] min_val = comp ? B : A;

// Extract sign and use the larger exponent as the base exponent
assign A_sign = max_val[31];
assign B_sign = min_val[31];
assign exponent = {1'b0,max_val[30:23] };


// Restore the hidden bit
// Normalized number  : hidden bit = 1
// Denormalized number: hidden bit = 0
assign A_mantissa_ext =
    (max_val[30:23] == 8'd0) ?
    {1'b0, max_val[22:0]} :
    {1'b1, max_val[22:0]};

wire [23:0] min_mantissa =
    (min_val[30:23] == 8'd0) ?
    {1'b0, min_val[22:0]} :
    {1'b1, min_val[22:0]};

// Align mantissas by right shifting the operand with the smaller exponent
wire [7:0] E_dif = max_val[30:23] - min_val[30:23];

assign B_mantissa_shifted =
    (E_dif >= 8'd24) ? 24'd0 :(min_mantissa >> E_dif);

// Generate Guard, Round and Sticky bits
// Guard : first bit shifted out
// Round : second bit shifted out
// Sticky: OR of all remaining shifted bits

always @(*) begin

    guard  = 1'b0;
    round  = 1'b0;
    sticky = 1'b0;

    if (E_dif == 0) begin
        guard  = 1'b0;
        round  = 1'b0;
        sticky = 1'b0;
    end

    else if (E_dif == 1) begin
        guard = min_mantissa[0];
    end

    else if (E_dif == 2) begin
        guard = min_mantissa[1];
        round = min_mantissa[0];
    end

    else if (E_dif < 24) begin
        guard = min_mantissa[E_dif-1];
        round = min_mantissa[E_dif-2];
        sticky = |min_mantissa[E_dif-3:0];
    end

    else begin
        // All mantissa bits are shifted out
        sticky = |min_mantissa;
    end

end

endmodule