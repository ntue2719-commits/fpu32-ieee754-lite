"""
gen_vectors_mul.py
===================
Sinh test vector (A, B) + expected_result cho module fp_multiplier_nonpipeline
(va cac ban pipeline 2-stage / 3-stage, vi logic tinh toan giong het nhau,
chi khac do tre pipeline).
 
Golden model ben duoi mo phong lai CHINH XAC tung buoc cua RTL:
fp_special_case_mul -> fp_mul_exp -> fp_mul_mantissa -> fp_normalize_mul
-> fp_round_trunc (passthrough) -> fp_pack, cong voi khoi "Final Result
Selection" trong fp_multiplier_nonpipeline.v (uu tien NaN > Inf*0 > Inf > 0
> normal).
 
QUAN TRONG: RTL khong xu ly rieng so denormal (exponent=0, fraction!=0) khi
nhan mantissa - no van gan hidden-bit = 1 nhu so normal (fp_mul_mantissa.v:
mantissa_A = {1'b1, fraction_A}). Day KHONG phai IEEE-754 chuan, nhung golden
model phai bat chuoc dung hanh vi nay de doi chieu bit-exact voi RTL hien tai
(neu muon RTL chuan IEEE thi phai sua RTL, xem ghi chu cuoi file).
 
Output: mul_vectors.txt
    Moi dong: <A_hex8> <B_hex8> <expected_hex8> <category>
    (testbench Verilog doc file nay bang $fscanf voi 4 truong %h %h %h %s)
"""
 
import random
 
MASK32 = 0xFFFFFFFF
MASK23 = 0x7FFFFF
MASK8 = 0xFF
 
QNAN = 0x7FC00000
 
 
# ---------------------------------------------------------------
# fp_special_case_mul (bit-exact theo RTL)
# ---------------------------------------------------------------
def fp_special_case_mul(exponent_A, fraction_A, exponent_B, fraction_B):
    A_zero = (exponent_A == 0) and (fraction_A == 0)
    B_zero = (exponent_B == 0) and (fraction_B == 0)
    A_inf = (exponent_A == 0xFF) and (fraction_A == 0)
    B_inf = (exponent_B == 0xFF) and (fraction_B == 0)
    A_nan = (exponent_A == 0xFF) and (fraction_A != 0)
    B_nan = (exponent_B == 0xFF) and (fraction_B != 0)
    return A_zero, B_zero, A_inf, B_inf, A_nan, B_nan
 
 
# ---------------------------------------------------------------
# fp_mul_exp : exponent_product = A + B - 127 (signed 10-bit trong RTL,
# nhung voi A,B in [0,255] gia tri nam trong [-127,383] nen khong tran)
# ---------------------------------------------------------------
def fp_mul_exp(exponent_A, exponent_B):
    return exponent_A + exponent_B - 127
 
 
# ---------------------------------------------------------------
# fp_mul_mantissa : (1.fraction_A) * (1.fraction_B), 24-bit x 24-bit = 48-bit
# ---------------------------------------------------------------
def fp_mul_mantissa(fraction_A, fraction_B):
    mantissa_A = 0x800000 | fraction_A
    mantissa_B = 0x800000 | fraction_B
    return mantissa_A * mantissa_B  # 48-bit
 
 
# ---------------------------------------------------------------
# fp_normalize_mul (bit-exact theo RTL, bao gom overflow/underflow clamp)
# ---------------------------------------------------------------
def fp_normalize_mul(mantissa_product, exponent_product):
    if (mantissa_product >> 47) & 1:  # 1x.xxx -> can shift phai 1 bit
        exponent_temp = exponent_product + 1
        fraction_temp = (mantissa_product >> 24) & MASK23
    else:  # 1.xxx
        exponent_temp = exponent_product
        fraction_temp = (mantissa_product >> 23) & MASK23
 
    if exponent_temp > 254:
        return 0xFF, 0, True, False
    elif exponent_temp <= 0:
        return 0, 0, False, True
    else:
        return exponent_temp & MASK8, fraction_temp, False, False
 
 
# ---------------------------------------------------------------
# Golden model top-level : mo phong fp_multiplier_nonpipeline (va cac ban
# pipeline khac, vi phan to hop logic la giong het nhau)
# ---------------------------------------------------------------
def golden_fp_mul(A, B):
    A &= MASK32
    B &= MASK32
 
    sign_A = (A >> 31) & 1
    exponent_A = (A >> 23) & MASK8
    fraction_A = A & MASK23
 
    sign_B = (B >> 31) & 1
    exponent_B = (B >> 23) & MASK8
    fraction_B = B & MASK23
 
    A_zero, B_zero, A_inf, B_inf, A_nan, B_nan = fp_special_case_mul(
        exponent_A, fraction_A, exponent_B, fraction_B
    )
 
    sign_out = sign_A ^ sign_B
 
    exponent_product = fp_mul_exp(exponent_A, exponent_B)
    mantissa_product = fp_mul_mantissa(fraction_A, fraction_B)
 
    exponent_norm, fraction_norm, _overflow, _underflow = fp_normalize_mul(
        mantissa_product, exponent_product
    )
 
    # fp_round_trunc : passthrough
    exponent_round, fraction_round = exponent_norm, fraction_norm
 
    normal_result = (sign_out << 31) | (exponent_round << 23) | fraction_round
 
    # "Final Result Selection" (always block trong fp_multiplier_*.v)
    if A_nan or B_nan:
        result = QNAN
    elif (A_inf and B_zero) or (B_inf and A_zero):
        result = QNAN
    elif A_inf or B_inf:
        result = (sign_out << 31) | (0xFF << 23)
    elif A_zero or B_zero:
        result = (sign_out << 31) | 0
    else:
        result = normal_result
 
    return result & MASK32
 
 
# =================================================================
# Sinh test vector
# =================================================================
def rand_float_bits(rng):
    """So normal ngau nhien (exponent 1..254, mantissa bat ky)."""
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
 
 
def gen_all(seed=42, n_random=400, n_denorm=100, n_edge=80):
    rng = random.Random(seed)
    vectors = []  # (A, B, category)
 
    # 1) Ngau nhien normal x normal
    for _ in range(n_random):
        A = rand_float_bits(rng)
        B = rand_float_bits(rng)
        vectors.append((A, B, "random_normal"))
 
    # 2) Special-case: moi cap to hop trong SPECIALS x SPECIALS
    for na, A in SPECIALS.items():
        for nb, B in SPECIALS.items():
            vectors.append((A, B, f"special_{na}_{nb}"))
 
    # 3) Special mix voi random normal (0/Inf/NaN nhan voi so thuong)
    for name, S in SPECIALS.items():
        for _ in range(10):
            R = rand_float_bits(rng)
            vectors.append((S, R, f"specialmix_{name}_A"))
            vectors.append((R, S, f"specialmix_{name}_B"))
 
    # 4) Denormal inputs (luu y: RTL gan hidden-bit=1 cho denormal, xem
    #    docstring dau file - golden model bat chuoc dung hanh vi nay)
    for _ in range(n_denorm):
        A = rand_denormal_bits(rng)
        B = rand_denormal_bits(rng) if rng.randint(0, 1) else rand_float_bits(rng)
        vectors.append((A, B, "denormal"))
 
    # 5) Overflow edge: exponent lon (exp_A + exp_B - 127 > 254)
    for _ in range(n_edge):
        A = (rng.randint(0, 1) << 31) | (rng.randint(200, 254) << 23) | rng.randint(0, MASK23)
        B = (rng.randint(0, 1) << 31) | (rng.randint(200, 254) << 23) | rng.randint(0, MASK23)
        vectors.append((A, B, "overflow_edge"))
 
    # 6) Underflow edge: exponent nho (exp_A + exp_B - 127 <= 0)
    for _ in range(n_edge):
        A = (rng.randint(0, 1) << 31) | (rng.randint(1, 40) << 23) | rng.randint(0, MASK23)
        B = (rng.randint(0, 1) << 31) | (rng.randint(1, 40) << 23) | rng.randint(0, MASK23)
        vectors.append((A, B, "underflow_edge"))
 
    # 7) x1.0 identity check (A * 1.0 = A, -1.0 * A = -A)
    ONE = 0x3F800000
    NEG_ONE = 0xBF800000
    for _ in range(30):
        A = rand_float_bits(rng)
        vectors.append((A, ONE, "identity_mul1"))
        vectors.append((A, NEG_ONE, "identity_mulneg1"))
 
    # 8) Boundary exponent product == 254 / == 255 (sat overflow)
    for _ in range(20):
        # exp_A + exp_B - 127 == 254  <=> exp_A + exp_B == 381
        exp_A = rng.randint(127, 254)
        exp_B = 381 - exp_A
        if 1 <= exp_B <= 254:
            A = (rng.randint(0, 1) << 31) | (exp_A << 23) | rng.randint(0, MASK23)
            B = (rng.randint(0, 1) << 31) | (exp_B << 23) | rng.randint(0, MASK23)
            vectors.append((A, B, "boundary_exp254"))
 
    return vectors
 
 
def main():
    vectors = gen_all()
    with open("mul_vectors.txt", "w") as f:
        for A, B, cat in vectors:
            expected = golden_fp_mul(A, B)
            f.write(f"{A:08X} {B:08X} {expected:08X} {cat}\n")
    print(f"Da sinh {len(vectors)} test vector -> mul_vectors.txt")
 
 
if __name__ == "__main__":
    main()