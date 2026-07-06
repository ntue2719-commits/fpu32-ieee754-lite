//==============================================================================
// Module : fp_round_trunc
// Function:
//   - Final rounding stage before IEEE-754 packing.
//   - Current implementation uses truncation, so the normalized mantissa
//     and exponent are passed through unchanged.
//   - Guard, Round, and Sticky (GRS) bits are kept in the interface for
//     future support of IEEE-754 rounding modes (e.g. Round-to-Nearest-Even)
//     without modifying the upstream datapath.
//==============================================================================

module fp_round_trunc(
    input  [7:0]  exponent_in,
    input  [22:0] mantissa_in,

    // Guard, Round and Sticky bits.
    // Currently unused because truncation is selected as the rounding method.
    input guard,
    input round,
    input sticky,

    output [7:0]  exponent_out,
    output [22:0] mantissa_out
);

    //--------------------------------------------------------------------------
    // Truncation rounding
    //
    // Simply discard any extra precision represented by the Guard, Round and
    // Sticky bits. The normalized exponent and mantissa are forwarded directly
    // to the packing stage.
    //--------------------------------------------------------------------------

    assign exponent_out = exponent_in;
    assign mantissa_out = mantissa_in;

    //--------------------------------------------------------------------------
    // Future extension:
    //
    // The existing GRS interface allows this module to be upgraded to support
    // IEEE-754 compliant rounding modes such as:
    //   - Round to Nearest, Ties to Even (RNE)
    //   - Round toward Zero (RTZ)
    //   - Round toward +Infinity (RUP)
    //   - Round toward -Infinity (RDN)
    //
    // Only this module would need to be modified, while fp_align,
    // fp_add_sub, fp_normalize_add and fp_pack can remain unchanged.
    //--------------------------------------------------------------------------

endmodule