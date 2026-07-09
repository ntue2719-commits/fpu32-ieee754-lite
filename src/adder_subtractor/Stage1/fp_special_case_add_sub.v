module fp_special_case_add_sub(
    input [31:0] A,
    input [31:0] B,
    input op,//op = 0 -> add, op =1 -> sub

    output reg special_valid,
    output reg [31:0] special_result
);

    localparam [31:0] QNAN = 32'h7FC00000;

    //Separate sign, exponent, mantissa
    wire A_sign = A[31];
    wire [7:0] A_exp = A[30:23];
    wire [22:0] A_mantissa = A[22:0];

    wire B_sign = B[31];
    wire [7:0] B_exp = B[30:23];
    wire [22:0] B_mantissa = B[22:0];

    //Definition of special case

    //Zero: exp = 0 and mantissa = 0
    wire is_a_zero = (A_exp == 8'b0) && (A_mantissa == 23'b0);
    wire is_b_zero = (B_exp == 8'b0) && (B_mantissa == 23'b0);

    //NaN: exponent = 8'hFF and mantissa != 0
    wire is_a_NaN = (A_exp == 8'hFF) && (A_mantissa != 23'b0);
    wire is_b_NaN = (B_exp == 8'hFF) && (B_mantissa != 23'b0);

    //Infinity: exponent = 8'hFF and mantissa = 0
    wire is_a_inf = (A_exp == 8'hFF) && (A_mantissa == 23'b0);
    wire is_b_inf = (B_exp == 8'hFF) && (B_mantissa == 23'b0);

    always @ (*) begin
        //set defualt value for special_valid and special_result
        special_valid = 1'b0; 
        special_result = 32'b0;
    
        //Case 1: NaN
        if(is_a_NaN && is_b_NaN) begin
            special_valid = 1'b1;
            special_result = QNAN;
        end
        else if(is_a_NaN) begin
            special_valid = 1'b1;
            special_result =QNAN;
        end
        else if(is_b_NaN) begin
            special_valid = 1'b1;
            special_result = QNAN;
        end

        //Case 2: infinity
        else if(is_a_inf && is_b_inf) begin
            special_valid = 1'b1;
            if(A_sign == B_sign) begin
                if(op) begin
                    special_result = QNAN;
                end
                else
                special_result = A;
            end
            else begin
                if(op) begin
                    special_result = A;
                end
                else
                    special_result = QNAN;
            end
        end
        else if(is_a_inf) begin
            special_valid = 1'b1;
            special_result = A;
        end
        else if(is_b_inf)begin
            special_valid = 1'b1;
            if(op) begin
                special_result = {~B_sign, B[30:0]};
            end
            else 
                special_result = B;
        end
    
        //Case 3: Zero
        else if(is_a_zero && is_b_zero) begin
            special_valid = 1'b1;            
            special_result = 32'b0; 
        end
        else if(is_a_zero) begin
            special_valid = 1'b1;
            if(op) begin
                special_result = {~B_sign, B[30:0]};//0 - finite = -finite
            end
            else 
                special_result = B;//0 + finite = finite
        end
        else if(is_b_zero) begin
            special_valid = 1'b1;
            special_result = A;
        end

    end

endmodule