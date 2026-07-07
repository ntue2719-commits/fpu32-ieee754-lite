//==============================================================================
// File      : fp_defs.v
// Project   : IEEE-754 Single-Precision Floating-Point Unit
// Author    : wis
// Description:
//   Common parameter definitions shared by all floating-point modules.
//   These constants define the IEEE-754 single-precision data format.
//==============================================================================
// +-----------+---------------------+---------------------------------------+
// | Sign (1b) |    Exponent (8b)    |             Fraction (23b)            |
// |  Bit [31] |    Bits [30:23]     |              Bits [22:0]              |
// +-----------+---------------------+---------------------------------------+
//
// 1. SIGN BIT (Bit 31):
//    - 1'b0 = Positive (+)
//    - 1'b1 = Negative (-)
//
// 2. EXPONENT FIELD (Bits 30:23):
//    - Width: 8 bits (Bias = 127)
//    - All 0s (8'h00) = Used for Zero (0) or Denormal numbers.
//    - All 1s (8'hFF) = Used for Infinity (Inf) or Not-a-Number (NaN).
//
// 3. FRACTION FIELD (Bits 22:0):
//    - Width: 23 bits (Does not include the implicit/hidden leading bit '1').
//
// 4. IEEE-754 SPECIAL CASES SUMMARY:
//    - Zero (±0)      : Exponent == 8'h00 and Fraction == 23'h0
//    - Infinity (±Inf): Exponent == 8'hFF and Fraction == 23'h0
//    - NaN (e.g. QNaN): Exponent == 8'hFF and Fraction != 23'h0
//    - Default QNaN   : 32'h7FC00000