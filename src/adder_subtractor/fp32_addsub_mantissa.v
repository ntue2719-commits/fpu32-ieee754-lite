
// Module : fp32_addsub_mantissa
// Project: FPU32 IEEE-754 - FAP201 (Nhom Adder-Subtractor)
// Tuan 2 : Cong/Tru phan mantissa sau khi da align (tuan 1)
//
// Logic:
//   - Neu sign_a == sign_b (cung dau)  -> phep CONG hai mantissa
//   - Neu sign_a != sign_b (khac dau)  -> phep TRU (lay lon tru nho)
//   - Dau ket qua: cong thi giu dau chung; tru thi lay dau cua so co
//     magnitude lon hon (so sanh truc tiep 2 mantissa da align, vi
//     sau align gia tri thuc cua 2 mantissa da cung thang do).
//
// Ghi chu: sum_result la 25-bit vi co the sinh carry (vd 1.5+1.5=3.0,
//          vuot khoi khoang [1,2)). diff_result la 24-bit, khong co
//          muon (borrow) vi da lay so lon tru so nho truoc.


module fp32_addsub_mantissa (
    input  wire        sign_a,
    input  wire        sign_b,
    input  wire [23:0] mant_a_aligned,
    input  wire [23:0] mant_b_aligned,

    output wire        result_sign,
    output wire        op_is_sub,
    output wire [24:0] sum_result,
    output wire [23:0] diff_result
);

    assign op_is_sub = sign_a ^ sign_b;

    //  Duong cong (cung dau) 
    assign sum_result = {1'b0, mant_a_aligned} + {1'b0, mant_b_aligned};

    //  Duong tru (khac dau): so sanh truc tiep 2 mantissa da align 
    wire a_mant_larger = (mant_a_aligned >= mant_b_aligned);
    assign diff_result = a_mant_larger ? (mant_a_aligned - mant_b_aligned)
                                        : (mant_b_aligned - mant_a_aligned);

    //  Dau ket qua 
    assign result_sign = op_is_sub ? (a_mant_larger ? sign_a : sign_b) : sign_a;

endmodule
