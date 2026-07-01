# FPU32 IEEE-754 Lite

A lightweight IEEE-754 single-precision floating-point unit implemented in Verilog.

This project supports:

- Floating-point addition
- Floating-point subtraction
- Floating-point multiplication
- Normalization
- Rounding
- Overflow and underflow detection

This project is developed as part of an academic digital design course.

---

## IEEE754 Single Precision Format

The project follows the IEEE754 Single Precision (32-bit) floating-point format.

| Field | Width | Bit Range |
|-------|--------|------------|
| Sign | 1 bit | [31] |
| Exponent | 8 bits | [30:23] |
| Fraction (Mantissa) | 23 bits | [22:0] |

### Hidden Bit

For normalized numbers, the leading bit of the significand is always 1 and is not stored explicitly. During arithmetic operations, this hidden bit is restored internally.

### Exponent Bias

IEEE754 Single Precision uses an exponent bias of 127.

```text
Actual Exponent = Stored Exponent − 127
```

### Value Representation

```text
Value = (-1)^Sign × (1.Fraction) × 2^(Exponent − 127)
```

---

## Architecture

### Top-Level Architecture
<p align="center">
  <img src="doc/images/Architecture_Block_Diagram.png" width="900">
</p>

The FPU consists of two arithmetic units:
- Floating-point adder-subtractor
- Floating-point multiplier

Both units share a common rounding module and are integrated through `fpu_top.v`.

### Adder-Subtractor Pipeline
<p align="center">
  <img src="doc/images/Architecture_adder_subtracter_unit.png" width="900">
</p>

```text
Alignment
    ↓
Addition / Subtraction
    ↓
Leading Zero Detection
    ↓
Normalization
    ↓
Rounding
```

### Multiplier Pipeline
<p align="center">
  <img src="doc/images/Architecture_multiplier_unit.png" width="900">
</p>

```text
Mantissa Multiplication
    ↓
Normalization
    ↓
Rounding
```
## Project Structure

```text
src/
├── fpu_add_sub/
│   ├── align.v
│   ├── lzd.v
│   ├── normalize.v
│   └── fpu_add_sub.v
│
├── fpu_mul/
│   ├── mul_mantissa.v
│   ├── normalize.v
│   └── fpu_mul.v
│
├── fpu_round.v
├── fpu_top.v
└── fpu_tb.v
```

---
## Team Members

| Full Name | Student ID | Responsibility |
|------------|------------|----------------|
| Nguyen Tri Tue | SE205019 | Floating-point adder-subtractor |
| Tran Le Tien Dat | SE205121 | Floating-point adder-subtractor |
| Le Nhat Nam | SE205267 | Floating-point multiplier |
| Tong Tran Dang | SE204445 | Floating-point multiplier |
| Ha Gia Bao | SE205134 | Floating-point adder-subtractor |

---
