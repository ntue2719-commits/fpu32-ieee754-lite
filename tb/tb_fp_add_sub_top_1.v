`timescale 1ns/1ps
module tb_2stage;
    reg clk = 0, rst_n = 0;
    reg  [31:0] A, B;
    reg         op;
    wire [31:0] result;
    integer     fd, log_fd, idx;
    reg  [31:0] exp_val;
    reg  [8*32-1:0] cat;

    fp_add_sub_top_2stage dut (.clk(clk), .rst_n(rst_n), .A(A), .B(B), .op(op), .result(result));

    always #5 clk = ~clk;   // 100 MHz

    initial begin
        fd = $fopen("vectors.txt", "r");
        log_fd = $fopen("results_2stage.log", "w");
        A = 0; B = 0; op = 0; idx = 0;
        repeat (5) @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        while (!$feof(fd)) begin
            if ($fscanf(fd, "%h %h %d %h %s\n", A, B, op, exp_val, cat) == 5) begin
                @(posedge clk);
                repeat (2) @(posedge clk);   // latency 2 chu ky cho ban 2-stage
                #1;
                if (result === exp_val)
                    $fdisplay(log_fd, "VEC %0d %0s PASS A=%08H B=%08H OP=%0d EXP=%08H GOT=%08H", idx, cat, A, B, op, exp_val, result);
                else
                    $fdisplay(log_fd, "VEC %0d %0s FAIL A=%08H B=%08H OP=%0d EXP=%08H GOT=%08H", idx, cat, A, B, op, exp_val, result);
                idx = idx + 1;
            end
        end
        $fclose(fd);
        $fclose(log_fd);
        $display("Done: %0d vectors", idx);
        $finish;
    end
endmodule