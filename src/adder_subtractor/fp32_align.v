// ============================================================
// Module : fp32_align
// Project: FPU32 IEEE-754 - FAP201 (Nhom Adder-Subtractor)
// Tuan 1 : Thiet ke loi toan hoc co ban
//   1. Tach truong Sign / Exponent / Mantissa tu so IEEE-754 32-bit
//   2. Them hidden bit (bit an) vao mantissa -> 24-bit (gia su normalized)
//   3. So sanh exponent cua A va B -> xac dinh so nao co exponent lon hon
//   4. Tinh do lech exponent (exp_diff)
//   5. Align (can chinh): shift phai mantissa cua so nho hon theo exp_diff
//
// Ghi chu: CHUA xu ly cac truong hop dac biet (Zero / NaN / Inf / Denormal)
//          -> se bo sung o tuan 2 (cung voi LZD va chuan hoa).
//          Pipeline 3-stage va Guard bits se them o tuan 3.
// ============================================================

module fp32_align (
    input  wire [31:0] a,              // So thuc A (IEEE-754 32-bit)
    input  wire [31:0] b,              // So thuc B (IEEE-754 32-bit)

    output wire        sign_a,        // Bit dau cua A
    output wire        sign_b,        // Bit dau cua B
    output wire [7:0]  exp_common,    // Exponent lon hon (dung lam exponent chung sau align)
    output wire [7:0]  exp_diff,      // Do lech exponent = |exp_a - exp_b|
    output wire        a_is_larger,   // 1 = exponent A >= exponent B

    output wire [23:0] mant_a_aligned, // Mantissa A sau align (24-bit, da co hidden bit)
    output wire [23:0] mant_b_aligned  // Mantissa B sau align (24-bit, da co hidden bit)
);

    // ---------------- 1. Tach truong ----------------
    wire [7:0]  exp_a  = a[30:23];
    wire [22:0] frac_a = a[22:0];

    wire [7:0]  exp_b  = b[30:23];
    wire [22:0] frac_b = b[22:0];

    assign sign_a = a[31];
    assign sign_b = b[31];

    // ---------------- 2. Them hidden bit (gia su so normalized) ----------------
    wire [23:0] mant_a_full = {1'b1, frac_a};   // {hidden bit, 23-bit fraction}
    wire [23:0] mant_b_full = {1'b1, frac_b};

    // ---------------- 3. So sanh exponent ----------------
    assign a_is_larger = (exp_a >= exp_b);

    wire [7:0] diff_ab = exp_a - exp_b;
    wire [7:0] diff_ba = exp_b - exp_a;

    assign exp_diff   = a_is_larger ? diff_ab : diff_ba;
    assign exp_common = a_is_larger ? exp_a   : exp_b;

    // ---------------- 4. Align: shift phai mantissa cua so nho hon ----------------
    // Neu shift >= 24 thi coi nhu mantissa = 0 (qua nho, khong con anh huong)
    wire [23:0] mant_a_shifted = (!a_is_larger && exp_diff < 24) ? (mant_a_full >> exp_diff) :
                                 (!a_is_larger)                  ? 24'b0 : mant_a_full;

    wire [23:0] mant_b_shifted = (a_is_larger && exp_diff < 24)  ? (mant_b_full >> exp_diff) :
                                 (a_is_larger)                   ? 24'b0 : mant_b_full;

    assign mant_a_aligned = mant_a_shifted;
    assign mant_b_aligned = mant_b_shifted;

endmodule
