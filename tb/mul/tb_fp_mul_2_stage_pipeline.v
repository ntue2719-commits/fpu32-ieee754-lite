`timescale 1ns/1ps

module tb_fp_mul_2_stage_pipeline;

    reg clk = 0;
    reg rst_n = 0;

    reg [31:0] A,B;

    wire [31:0] result;

    integer fd,log_fd,idx;

    reg [31:0] exp_val;
    reg [8*32-1:0] cat;

    fp_multiplier_2_stage_pipeline dut(
        .clk(clk),
        .rst_n(rst_n),
        .A(A),
        .B(B),
        .result(result)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("fp_mul_pipe2.vcd");
        $dumpvars(0, tb_fp_mul_2_stage_pipeline);
        fd = $fopen("verification/mul/mul_vectors.txt","r");
        log_fd = $fopen("verification/mul/results_2_stage_pipeline.log","w");

        A = 0;
        B = 0;
        idx = 0;

        repeat(5) @(posedge clk);

        rst_n = 1;

        @(posedge clk);

        while(!$feof(fd)) begin
            if($fscanf(fd,"%h %h %h %s\n",
                A,B,exp_val,cat) == 4) begin

                @(posedge clk);

                repeat(2) @(posedge clk);

                #1;

                if(result === exp_val)
                    $fdisplay(log_fd,
                    "VEC %0d %0s PASS A=%08H B=%08H EXP=%08H GOT=%08H",
                    idx,cat,A,B,exp_val,result);

                else
                    $fdisplay(log_fd,
                    "VEC %0d %0s FAIL A=%08H B=%08H EXP=%08H GOT=%08H",
                    idx,cat,A,B,exp_val,result);

                idx = idx + 1;
            end
        end

        $display("Done : %0d vectors",idx);

        $fclose(fd);
        $fclose(log_fd);

        $finish;
    end

endmodule