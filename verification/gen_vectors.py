"""
gen_vectors.py
==============
Sinh test vector (A, B, op) + expected_result cho module fp_add_sub_top
(và các bản pipeline 3-stage / 2-stage, vì logic tính toán giống hệt nhau,
chỉ khác độ trễ pipeline).

Golden model bên dưới mô phỏng lại CHÍNH XÁC từng bước của RTL:
fp_compare -> fp_align -> fp_add_sub_core -> fp_lzd -> fp_normalize_add_sub
-> fp_round_trunc (passthrough) -> fp_pack, cùng fp_special_case_add_sub.

Output: vectors.txt
    Mỗi dòng: <A_hex8> <B_hex8> <op> <expected_hex8> <category>
    (testbench Verilog sẽ đọc file này bằng $fscanf)
"""

import random

MASK32 = 0xFFFFFFFF
MASK24 = 0xFFFFFF
MASK23 = 0x7FFFFF
MASK8 = 0xFF

QNAN = 0x7FC00000


# ---------------------------------------------------------------
# fp_compare : trả về 1 nếu A >= B (theo đúng logic RTL, dùng khi
# fp_align gọi với sign bit ép về 0 -> chỉ còn nhánh NaN/zero/positive)
# ---------------------------------------------------------------
def fp_compare(A, B):
    a_exp = (A >> 23) & MASK8
    a_mant = A & MASK23
    b_exp = (B >> 23) & MASK8
    b_mant = B & MASK23
    a_sign = (A >> 31) & 1
    b_sign = (B >> 31) & 1

    a_is_nan = (a_exp == 0xFF) and (a_mant != 0)
    b_is_nan = (b_exp == 0xFF) and (b_mant != 0)
    a_is_zero = (A & 0x7FFFFFFF) == 0
    b_is_zero = (B & 0x7FFFFFFF) == 0

    if a_is_nan or b_is_nan:
        return 0
    if a_is_zero and b_is_zero:
        return 1
    if A == B:
        return 1
    if a_sign != b_sign:
        return 1 if a_sign == 0 else 0
    if a_sign == 0:  # both positive
        if a_exp != b_exp:
            return 1 if a_exp > b_exp else 0
        else:
            return 1 if a_mant > b_mant else 0
    else:  # both negative
        if a_exp != b_exp:
            return 1 if a_exp < b_exp else 0
        else:
            return 1 if a_mant < b_mant else 0


def restore_hidden(exp, mant):
    return mant if exp == 0 else (0x800000 | mant)


# ---------------------------------------------------------------
# fp_align
# ---------------------------------------------------------------
def fp_align(A, B_internal):
    cmp_A = A & 0x7FFFFFFF
    cmp_B = B_internal & 0x7FFFFFFF
    comp = fp_compare(cmp_A, cmp_B)

    max_val = A if comp else B_internal
    min_val = B_internal if comp else A

    A_sign = (max_val >> 31) & 1
    B_sign = (min_val >> 31) & 1
    exponent = (max_val >> 23) & MASK8

    max_exp = (max_val >> 23) & MASK8
    max_mant = max_val & MASK23
    min_exp = (min_val >> 23) & MASK8
    min_mant = min_val & MASK23

    A_mantissa_ext = restore_hidden(max_exp, max_mant)
    min_mantissa = restore_hidden(min_exp, min_mant)

    E_dif = (max_exp - min_exp) & MASK8
    if E_dif >= 24:
        B_mantissa_shifted = 0
    else:
        B_mantissa_shifted = (min_mantissa >> E_dif) & MASK24

    return A_sign, B_sign, exponent, A_mantissa_ext, B_mantissa_shifted


# ---------------------------------------------------------------
# fp_add_sub_core
# ---------------------------------------------------------------
def fp_add_sub_core(A_sign, B_sign, A_mantissa, B_mantissa):
    if A_sign == B_sign:
        return (A_mantissa + B_mantissa) & 0x1FFFFFF  # 25-bit
    else:
        return (A_mantissa - B_mantissa) & 0x1FFFFFF  # giả định luôn >=0


# ---------------------------------------------------------------
# fp_lzd (đúng bảng priority-encoder trong RTL, input 24-bit)
# ---------------------------------------------------------------
def fp_lzd(mantissa24):
    for i in range(23, -1, -1):
        if (mantissa24 >> i) & 1:
            return 23 - i
    return 24


# ---------------------------------------------------------------
# fp_normalize_add_sub
# ---------------------------------------------------------------
def fp_normalize_add_sub(sum_mantissa25, exponent, shift_left):
    if sum_mantissa25 == 0:
        return 0, 0
    if (sum_mantissa25 >> 24) & 1:  # carry-out
        # Carry-out: shift right by 1 bit, increment exponent by 1
        if exponent == 0xFE or exponent == 0xFF:
            # Exponent would reach/exceed 0xFF after +1 -> saturate to Infinity
            return 0xFF, 0
        else:
            mantissa_norm = (sum_mantissa25 >> 1) & MASK23  # mantissa[23:1]
            exponent_norm = exponent + 1
            return exponent_norm, mantissa_norm
    if exponent > shift_left:
        mantissa_norm = (sum_mantissa25 << shift_left) & MASK23
        exponent_norm = exponent - shift_left
        return exponent_norm, mantissa_norm
    else:
        mantissa_norm = (sum_mantissa25 << shift_left) & MASK23
        return 0, mantissa_norm


# ---------------------------------------------------------------
# fp_special_case_add_sub (bit-exact theo RTL)
# ---------------------------------------------------------------
def fp_special_case_add_sub(A, B, op):
    A_sign = (A >> 31) & 1
    A_exp = (A >> 23) & MASK8
    A_mant = A & MASK23
    B_sign = (B >> 31) & 1
    B_exp = (B >> 23) & MASK8
    B_mant = B & MASK23

    is_a_zero = (A_exp == 0) and (A_mant == 0)
    is_b_zero = (B_exp == 0) and (B_mant == 0)
    is_a_nan = (A_exp == 0xFF) and (A_mant != 0)
    is_b_nan = (B_exp == 0xFF) and (B_mant != 0)
    is_a_inf = (A_exp == 0xFF) and (A_mant == 0)
    is_b_inf = (B_exp == 0xFF) and (B_mant == 0)

    if is_a_nan or is_b_nan:
        return True, QNAN
    if is_a_inf and is_b_inf:
        if A_sign == B_sign:
            return (True, QNAN) if op else (True, A)
        else:
            return (True, A) if op else (True, QNAN)
    if is_a_inf:
        return True, A
    if is_b_inf:
        if op:
            return True, ((~B_sign & 1) << 31) | (B & 0x7FFFFFFF)
        else:
            return True, B
    if is_a_zero and is_b_zero:
        return True, 0
    if is_a_zero:
        if op:
            return True, ((~B_sign & 1) << 31) | (B & 0x7FFFFFFF)
        else:
            return True, B
    if is_b_zero:
        return True, A
    return False, 0


# ---------------------------------------------------------------
# Golden model top-level : mô phỏng fp_add_sub_top
# ---------------------------------------------------------------
def golden_fp_add_sub(A, B, op):
    A &= MASK32
    B &= MASK32

    special_valid, special_result = fp_special_case_add_sub(A, B, op)

    B_internal = ((~(B >> 31) & 1) << 31) | (B & 0x7FFFFFFF) if op else B

    A_sign, B_sign, exponent, A_mant_ext, B_mant_shifted = fp_align(A, B_internal)
    sum_mantissa = fp_add_sub_core(A_sign, B_sign, A_mant_ext, B_mant_shifted)
    count_zero = fp_lzd(sum_mantissa & MASK24)
    exponent_norm, mantissa_norm = fp_normalize_add_sub(sum_mantissa, exponent, count_zero)

    result_sign = 0 if sum_mantissa == 0 else A_sign

    # fp_round_trunc : passthrough
    exponent_out, mantissa_out = exponent_norm, mantissa_norm

    result_pack = (result_sign << 31) | (exponent_out << 23) | mantissa_out

    if special_valid:
        return special_result & MASK32
    else:
        return result_pack & MASK32


# =================================================================
# Sinh test vector
# =================================================================
def rand_float_bits(rng):
    """Số normal ngẫu nhiên (exponent 1..254, mantissa bất kỳ)."""
    sign = rng.randint(0, 1)
    exp = rng.randint(1, 254)
    mant = rng.randint(0, MASK23)
    return (sign << 31) | (exp << 23) | mant


def rand_denormal_bits(rng):
    sign = rng.randint(0, 1)
    mant = rng.randint(1, MASK23)
    return (sign << 31) | (0 << 23) | mant


SPECIALS = {
    "+0": 0x00000000,
    "-0": 0x80000000,
    "+Inf": 0x7F800000,
    "-Inf": 0xFF800000,
    "NaN": 0x7FC00001,
}


def gen_all(seed=42, n_random=300, n_cancel=100, n_denorm=100):
    rng = random.Random(seed)
    vectors = []  # (A, B, op, category)

    # 1) Ngẫu nhiên normal-normal, cả 2 op
    for _ in range(n_random):
        A = rand_float_bits(rng)
        B = rand_float_bits(rng)
        op = rng.randint(0, 1)
        vectors.append((A, B, op, "random_normal"))

    # 2) Special-case: mọi cặp tổ hợp trong SPECIALS x SPECIALS, cả 2 op
    for na, A in SPECIALS.items():
        for nb, B in SPECIALS.items():
            for op in (0, 1):
                vectors.append((A, B, op, f"special_{na}_{nb}"))

    # 3) Special mix với random normal (0/Inf/NaN cộng/trừ với số thường)
    for name, S in SPECIALS.items():
        for _ in range(10):
            R = rand_float_bits(rng)
            op = rng.randint(0, 1)
            vectors.append((S, R, op, f"specialmix_{name}_A"))
            vectors.append((R, S, op, f"specialmix_{name}_B"))

    # 4) Cancellation: A - A, và A gần bằng B khác dấu -> LZD lớn
    for _ in range(n_cancel):
        A = rand_float_bits(rng)
        vectors.append((A, A, 1, "cancel_exact"))  # A - A = 0
        # gần bằng: cùng exponent, mantissa lệch chút it
        exp = rng.randint(1, 254)
        m1 = rng.randint(0, MASK23)
        m2 = max(0, min(MASK23, m1 + rng.randint(-4, 4)))
        sgn = rng.randint(0, 1)
        A2 = (sgn << 31) | (exp << 23) | m1
        B2 = (sgn << 31) | (exp << 23) | m2
        vectors.append((A2, B2, 1, "cancel_near"))

    # 5) Denormal inputs
    for _ in range(n_denorm):
        A = rand_denormal_bits(rng)
        B = rand_denormal_bits(rng) if rng.randint(0, 1) else rand_float_bits(rng)
        op = rng.randint(0, 1)
        vectors.append((A, B, op, "denormal"))

    # 6) Overflow (exponent gần max) và underflow (exponent gần min)
    for _ in range(30):
        A = (rng.randint(0, 1) << 31) | (254 << 23) | rng.randint(0, MASK23)
        B = (rng.randint(0, 1) << 31) | (254 << 23) | rng.randint(0, MASK23)
        vectors.append((A, B, 0, "overflow_edge"))
        A = (rng.randint(0, 1) << 31) | (1 << 23) | rng.randint(0, MASK23)
        B = (rng.randint(0, 1) << 31) | (1 << 23) | rng.randint(0, MASK23)
        vectors.append((A, B, 1, "underflow_edge"))

    return vectors


def main():
    vectors = gen_all()
    with open("vectors.txt", "w") as f:
        for A, B, op, cat in vectors:
            expected = golden_fp_add_sub(A, B, op)
            f.write(f"{A:08X} {B:08X} {op} {expected:08X} {cat}\n")
    print(f"Da sinh {len(vectors)} test vector -> vectors.txt")


if __name__ == "__main__":
    main()
