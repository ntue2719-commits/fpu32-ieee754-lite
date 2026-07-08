module fp_normalize_add_sub(
    input  [24:0] mantissa,
    input  [7:0] exponent,
    input  [4:0] shift_left,

    output reg [7:0] exponent_norm,
    output reg [22:0] mantissa_norm
);


    always @ (*) begin
        //Case 1: sum = 0
        if(mantissa == 25'b0) begin
            exponent_norm = 8'b0;
            mantissa_norm = 23'b0;
        end

        //Case 2: Carry-out after addition
        else if(mantissa[24]) begin
           // Carry-out: shift phai 1 bit, tang exponent len 1
            if (exponent == 8'hFE || exponent == 8'hFF) begin
                // Exponent sau khi +1 se cham/vuot 0xFF -> saturate thanh Infinity
                exponent_norm = 8'hFF;
                mantissa_norm = 23'b0;
            end
            else begin
                mantissa_norm = mantissa[23:1];
                exponent_norm = exponent + 1'b1;
            end
        end
        //Case 3: Underflow and shift left count (lzd)
        else if(exponent > shift_left) begin
            mantissa_norm = mantissa[22:0] <<shift_left;
            exponent_norm = exponent - shift_left;
        end
        else begin
            mantissa_norm = mantissa[22:0] <<shift_left;
            exponent_norm = 8'b0;
        end
    end
endmodule