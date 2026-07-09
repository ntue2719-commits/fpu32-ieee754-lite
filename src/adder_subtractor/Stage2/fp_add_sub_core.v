module fp_add_sub_core (
    input A_sign,
    input B_sign,
    input [23:0] A_mantissa,
    input [23:0] B_mantissa,
    output reg [24:0] sum_mantissa
);
    always @(*) begin
        if(A_sign == B_sign) begin
            // Same sign -> add aligned magnitudes
             sum_mantissa = {1'b0, A_mantissa} + {1'b0, B_mantissa}; 
        end
        else begin
            // Assume |A| >= |B| (guaranteed by fp_align)
            sum_mantissa = {1'b0, A_mantissa} - {1'b0, B_mantissa}; 
        end      
    end
endmodule