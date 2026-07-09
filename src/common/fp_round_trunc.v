//==============================================================================
// Module : fp_round_trunc
// Function:
//   - Final rounding stage before IEEE-754 packing.
//   - Current implementation uses truncation, so the normalized mantissa
//     and exponent are passed through unchanged.
//==============================================================================

module fp_round_trunc(
    input  [7:0]  exponent_in,
    input  [22:0] mantissa_in,
   
    output [7:0]  exponent_out,
    output [22:0] mantissa_out
);

    // Truncation rounding
    // No additional rounding logic is applied. The normalized exponent and
    // mantissa are forwarded directly to the packing stage 
    assign exponent_out = exponent_in;
    assign mantissa_out = mantissa_in;
endmodule