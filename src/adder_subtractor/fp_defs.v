//==============================================================================
// File      : fp_defs.v
// Project   : IEEE-754 Single-Precision Floating-Point Unit
// Author    : wis
// Description:
//   Common parameter definitions shared by all floating-point modules.
//   These constants define the IEEE-754 single-precision data format.
//==============================================================================

`ifndef FP_DEFS_V
`define FP_DEFS_V

//------------------------------------------------------------------------------
// IEEE-754 Single-Precision Format
//------------------------------------------------------------------------------
`define FP_WIDTH      32      // Total floating-point width
`define EXP_WIDTH      8      // Exponent field width
`define FRAC_WIDTH    23      // Fraction (stored mantissa) width
`define MANT_WIDTH    24      // Mantissa width including hidden bit
`define EXP_BIAS     127      // Exponent bias

`endif
/*
----32 Bit Float----
Bits 0:22 - Mantissa
Bits 23:30 - Exponent
Bits 31 - sign bit
*/

/*
----IEEE-754 Encodings---- 
Exponent    Fraction    Object
    0           0       zero
    0        non-zero   denormalised number
  1-254     anything    floating point
   255          0       infinity
   255       non-zero   NaN (Not a Number)
*/


/*
Value of Float = (-1)^S x (1+fraction) x 2^(exponent-bias)
S-sign bit ; fraction - mantissa(without implicit one) ; bias - 127 
*/
