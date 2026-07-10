//==============================================================================
// fpu_top.v
//
// IEEE-754 FPU lite (add/sub/mul) - Top-level (non-pipeline)
//
// PURPOSE:
// Ghep module fp_add_sub_top (non-pipeline) va fp_multiplier_nonpipeline
// lai thanh 1 khoi FPU duy nhat, chon phep tinh bang tin hieu "op".
//
// Day la ban KHONG pipeline (thuan to hop, khong co clk/rst) vi phan so sanh
// non-pipe / 2-stage / 3-stage da duoc lam rieng o cac module con (add_sub,
// multiplier). File nay chi de xac dinh lai kien truc FPU-lite hoan chinh.
//
// op encoding:
//   op = 2'b00 -> ADD   (A + B)
//   op = 2'b01 -> SUB   (A - B)
//   op = 2'b10 -> MUL   (A * B)
//   op = 2'b11 -> reserved (mac dinh tra ve nhu ADD)
//==============================================================================

module fpu_top (
    input  [31:0] A,
    input  [31:0] B,
    input  [1:0]  op,
    output reg [31:0] result
);

    localparam OP_ADD = 2'b00;
    localparam OP_SUB = 2'b01;
    localparam OP_MUL = 2'b10;

    //--------------------------------------------------------------------
    // Adder / Subtractor (non-pipeline)
    // fp_add_sub_top tu nhan tin hieu op rieng: 0 = add, 1 = sub
    //--------------------------------------------------------------------
    wire [31:0] add_sub_result;

    fp_add_sub_top u_add_sub (
        .A      (A),
        .B      (B),
        .op     (op[0]),
        .result (add_sub_result)
    );

    //--------------------------------------------------------------------
    // Multiplier (non-pipeline)
    //--------------------------------------------------------------------
    wire [31:0] mul_result;

    fp_multiplier_nonpipeline u_mul (
        .A      (A),
        .B      (B),
        .result (mul_result)
    );

    //--------------------------------------------------------------------
    // Chon ket qua theo op
    //--------------------------------------------------------------------
    always @(*) begin
        case (op)
            OP_ADD:  result = add_sub_result;
            OP_SUB:  result = add_sub_result;
            OP_MUL:  result = mul_result;
            default: result = add_sub_result;
        endcase
    end

endmodule
