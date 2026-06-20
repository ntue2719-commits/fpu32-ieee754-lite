## IEEE754 Single Precision Format

The project follows the IEEE754 Single Precision (32-bit) floating-point format.

| Field               | Width   | Bit Range |
| ------------------- | ------- | --------- |
| Sign                | 1 bit   | [31]      |
| Exponent            | 8 bits  | [30:23]   |
| Fraction (Mantissa) | 23 bits | [22:0]    |

### Hidden Bit

For normalized numbers, the leading bit of the significand is always 1 and is not stored explicitly. During arithmetic operations, this hidden bit is restored internally.

### Exponent Bias

IEEE754 Single Precision uses an exponent bias of 127.

Actual Exponent = Stored Exponent − 127

### Value Representation

Value = (-1)^Sign × (1.Fraction) × 2^(Exponent − 127)
