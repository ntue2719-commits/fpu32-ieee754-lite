//==============================================================================
// tb_fpu_top.v
//
// Testbench don gian cho fpu_top.v (IEEE-754 FPU lite: add/sub/mul)
// Chi can 1 truong hop test de xem dang chay dung, xuat waveform (.vcd)
// de kiem tra bang GTKWave. Khong can self-check PASS/FAIL phuc tap.
//==============================================================================
`timescale 1ns/1ps

module tb_fpu_top;

    reg  [31:0] A, B;
    reg  [1:0]  op;
    wire [31:0] result;

    fpu_top dut (
        .A      (A),
        .B      (B),
        .op     (op),
        .result (result)
    );

    // In ket qua ra console moi khi input thay doi
    always @(A or B or op) begin
        #5; // cho logic to hop on dinh roi moi in
        $display("[%0t] A=%08h B=%08h op=%0b -> result=%08h", $time, A, B, op, result);
    end

    initial begin
        $dumpfile("fpu_top.vcd");
        $dumpvars(0, tb_fpu_top);

        $display("========================================================");
        $display(" TEST fpu_top.v (IEEE-754 FPU lite: add/sub/mul)");
        $display("========================================================");

        // ------------------------------------------------------------
        // 1 truong hop test duy nhat: A = 3.0, B = 2.0
        // Lan luot thu ca 3 phep tinh tren cung 1 cap gia tri A, B
        //   ADD: 3.0 + 2.0 = 5.0   (0x40A00000)
        //   SUB: 3.0 - 2.0 = 1.0   (0x3F800000)
        //   MUL: 3.0 * 2.0 = 6.0   (0x40C00000)
        // ------------------------------------------------------------
        A = 32'h40400000; // 3.0
        B = 32'h40000000; // 2.0

        op = 2'b00; #10; // ADD -> ky vong 0x40A00000
        op = 2'b01; #10; // SUB -> ky vong 0x3F800000
        op = 2'b10; #10; // MUL -> ky vong 0x40C00000

        #10;
        $display("========================================================");
        $display(" DONE.");
        $display("========================================================");

        $finish;
    end

endmodule
