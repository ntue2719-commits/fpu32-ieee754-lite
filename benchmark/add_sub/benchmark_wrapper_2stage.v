`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/12/2026 03:36:08 PM
// Design Name: 
// Module Name: benchmark_wrapper_2stage
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module benchmark_wrapper_2stage(

    input clk,
    input rst_n

);

//====================================================
// Benchmark Registers
//====================================================

(* DONT_TOUCH = "TRUE" *) reg [31:0] A_reg;
(* DONT_TOUCH = "TRUE" *) reg [31:0] B_reg;
(* DONT_TOUCH = "TRUE" *) reg        op_reg;

wire [31:0] result_wire;

(* DONT_TOUCH = "TRUE" *) reg [31:0] result_reg;

//====================================================
// Input Registers
//====================================================

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        A_reg  <= 32'h3F800000;
        B_reg  <= 32'h40000000;
        op_reg <= 1'b0;
    end
    else
    begin
        A_reg  <= A_reg + 32'h00010000;
        B_reg  <= B_reg + 32'h00008000;
        op_reg <= ~op_reg;
    end
end

//====================================================
// DUT
//====================================================

(* DONT_TOUCH = "TRUE" *)
fp_add_sub_top_2stage DUT
(
    .clk(clk),
    .rst_n(rst_n),
    .A(A_reg),
    .B(B_reg),
    .op(op_reg),
    .result(result_wire)
);

//====================================================
// Output Register
//====================================================

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        result_reg <= 32'd0;
    else
        result_reg <= result_wire;
end

endmodule
