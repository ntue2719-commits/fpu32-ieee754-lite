`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/12/2026 11:12:08 PM
// Design Name: 
// Module Name: benchmark_wrapper_mul_2stage
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


module benchmark_wrapper_mul_2stage
(
    input clk,
    input rst_n
);

(* DONT_TOUCH = "TRUE" *) reg [31:0] A_reg;
(* DONT_TOUCH = "TRUE" *) reg [31:0] B_reg;

wire [31:0] result_wire;

(* DONT_TOUCH = "TRUE" *) reg [31:0] result_reg;

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        A_reg <= 32'h3F800000;
        B_reg <= 32'h40000000;
    end
    else
    begin
        A_reg <= A_reg + 32'h00010000;
        B_reg <= B_reg + 32'h00008000;
    end
end

(* DONT_TOUCH = "TRUE" *)
fp_multiplier_2_stage_pipeline DUT
(
    .clk(clk),
    .rst_n(rst_n),
    .A(A_reg),
    .B(B_reg),
    .result(result_wire)
);

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        result_reg <= 32'd0;
    else
        result_reg <= result_wire;
end

endmodule
