
// Module : fp32_normalize
// Tuan 2 : Chuan hoa ket qua sau cong/tru, dua ve dang IEEE-754
//
//   - Truong hop CONG: neu co carry (bit 24 = 1) -> shift phai 1 bit,
//     tang exponent 1. Khong carry -> giu nguyen.
//   - Truong hop TRU: shift trai dung "lzd_count" bit (lay tu LZD),
//     giam exponent di dung lzd_count.
//
// Ghi chu: chua xu ly truong hop ket qua = 0 tuyet doi hay tran so
//          (overflow/underflow) -> bo sung sau cung voi phan xu ly
//          so dac biet (Zero/NaN/Infinity).


module fp32_normalize (
    input  wire        op_is_sub,
    input  wire [24:0] sum_result,
    input  wire [23:0] diff_result,
    input  wire [4:0]  lzd_count,
    input  wire [7:0]  exp_common,

    output wire [22:0] norm_mantissa,
    output wire [7:0]  norm_exponent
);

    //  Chuan hoa duong CONG 
    wire        add_carry      = sum_result[24];
    wire [23:0] add_normalized = add_carry ? sum_result[24:1] : sum_result[23:0];
    wire [7:0]  add_exp        = add_carry ? (exp_common + 8'd1) : exp_common;

    //  Chuan hoa duong TRU
    wire [23:0] sub_normalized = diff_result << lzd_count;
    wire [7:0]  sub_exp        = exp_common - lzd_count;

    //  Chon theo loai phep toan 
    wire [23:0] normalized = op_is_sub ? sub_normalized : add_normalized;
    assign norm_exponent   = op_is_sub ? sub_exp        : add_exp;

    // Bo hidden bit (bit 23) truoc khi xuat ra mantissa 23-bit luu tru
    assign norm_mantissa = normalized[22:0];

endmodule
