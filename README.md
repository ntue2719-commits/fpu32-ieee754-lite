# FPU32 IEEE-754 Lite

A modular, pipelined IEEE-754 single-precision floating-point unit implemented in Verilog, targeting the EBAZ4205 FPGA.

This project supports:

- Floating-point addition
- Floating-point subtraction
- Floating-point multiplication
- Normalization
- Rounding / truncation
- Special-case handling (NaN, Infinity, Zero)
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

### Design Philosophy: Reusable Floating-Point Datapath

The adder-subtractor (`fpu_add_sub.v`) and multiplier (`fpu_mul.v`) are implemented as two independent datapaths — they do not share alignment, arithmetic core, leading-zero-detection, or normalization logic, since these steps differ fundamentally between the two operations (add/sub cancellation may require shifting many bits, while multiplier normalization needs at most a 1-bit shift).

Both datapaths converge at two final, format-defined stages, which are shared:

- `fp_round_trunc.v` — Rounding / truncation (shared)
- `fp_pack.v` — Result packing into IEEE-754 format (shared)

This is where reuse makes sense: the two units diverge in their early, algorithm-specific stages, then converge at the stages that only depend on the final normalized mantissa and exponent.

### Design Principle: Special-Case Isolation

Special-case handling (NaN, Infinity, Zero, etc.) is kept out of the core datapath modules:

- `fp_align` — performs alignment only, has no awareness of special cases
- `fp_special_case_add_sub` / `fp_special_case_mul` — handle all IEEE-754 exceptions for each pipeline (note: multiply special cases differ from add/sub, e.g. `0 × ∞ = NaN`, so they live in separate files)
- `fpu_add_sub.v` / `fpu_mul.v` — top-level modules that route between the normal path and the special-case path

### Top-Level Architecture
<p align="center">
  <img src="doc/images/Architecture_Block_Diagram.png" width="900">
</p>

The FPU consists of two independent arithmetic units — a floating-point adder-subtractor and a floating-point multiplier — both built on the shared rounding and packing modules, integrated through `fpu_top.v`.

### Adder-Subtractor Pipeline
<p align="center">
  <img src="doc/images/Architecture_adder_subtracter_unit.png" width="900">
</p>

```text
A, B
  │
  ▼
fp_special_case_add_sub ──── special_valid = 1 ────► Result
  │
  ▼
fp_compare_mag
  │
  ▼
fp_align
  │
  ▼
fp_add_sub_core
  │
  ▼
fp_lzd
  │
  ▼
fp_normalize_add
  │
  ▼
fp_round_trunc   ← Shared
  │
  ▼
fp_pack          ← Shared
  │
  ▼
Result
```

### Multiplier Pipeline
<p align="center">
  <img src="doc/images/Architecture_multiplier_unit.png" width="900">
</p>

```text
A, B
  │
  ▼
fp_special_case_mul ──── special_valid = 1 ────► Result
  │
  ▼
fp_mul_exp
  │
  ▼
fp_mul_mantissa
  │
  ▼
fp_normalize_mul
  │
  ▼
fp_round_trunc   ← Shared
  │
  ▼
fp_pack          ← Shared
  │
  ▼
Result
```

---

## FPGA Pipeline Evaluation

Both `fpu_add_sub.v` and `fpu_mul.v` are each synthesized in three pipeline configurations — Non-pipeline, 2-stage, and 3-stage — using the same methodology, so results can be compared side by side across both units.

| Unit | Configuration | LUT | FF | Fmax |
|------|---------------|-----|----|----|
| Adder-subtractor | Non-pipeline |  |  |   |
| Adder-subtractor | 2-stage |  |  |   |
| Adder-subtractor | 3-stage | |  |  |
| Multiplier | Non-pipeline | |  |  |
| Multiplier | 2-stage | |  |  |
| Multiplier | 3-stage |  |  |  |

> Numbers above are illustrative for the adder-subtractor; replace with real synthesis results once available. Multiplier figures are pending — `fpu_mul.v` currently has a fixed 2-stage implementation and needs non-pipeline and 3-stage variants added to complete the comparison.

Expected analysis points:
- LUT usage increases by ~20% per added pipeline stage
- FF count increases due to added pipeline registers
- Fmax increases by nearly 3× from non-pipeline to 3-stage
- Overall throughput improves significantly with pipelining

Each unit's RTL and pipeline structure remain independent (`fpu_add_sub.v` and `fpu_mul.v` are not merged into a single top module) — only the synthesis results are compared together here.

## Project Structure

```text
src/
├── common/
│   ├── fp_round_trunc.v      ✅ Shared
│   └── fp_pack.v             ✅ Shared
│
├── fpu_add_sub/
│   ├── fp_compare_mag.v
│   ├── fp_align.v
│   ├── fp_add_sub_core.v
│   ├── fp_lzd.v
│   ├── fp_normalize_add.v
│   ├── fp_special_case_add_sub.v
│   └── fpu_add_sub.v
│
├── fpu_mul/
│   ├── fp_mul_exp.v
│   ├── fp_mul_mantissa.v
│   ├── fp_normalize_mul.v
│   ├── fp_special_case_mul.v
│   └── fpu_mul.v
│
└── fpu_top.v
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