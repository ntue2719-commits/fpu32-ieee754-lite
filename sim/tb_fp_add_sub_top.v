`timescale 1ns/1ps
module tb_nopipe;
    reg  [31:0] A, B;
    reg         op;
    wire [31:0] result;
    integer     fd, log_fd, idx;
    reg  [31:0] exp_val;
    reg  [8*32-1:0] cat;

    fp_add_sub_top dut (.A(A), .B(B), .op(op), .result(result));

    initial begin
        fd = $fopen("vectors.txt", "r");
        log_fd = $fopen("results_nopipe.log", "w");
        idx = 0;
        while (!$feof(fd)) begin
            if ($fscanf(fd, "%h %h %d %h %s\n", A, B, op, exp_val, cat) == 5) begin
                #10;
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