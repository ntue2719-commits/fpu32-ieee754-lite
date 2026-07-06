module fp_normalize_add_sub(
    input  [24:0] mantissa,
    input  [8:0] exponent,
    input  [4:0] shift_left,

    output reg [7:0] exponent_norm,
    output reg [22:0] mantissa_norm
);


    always @ (*) begin
        //Case 1: sum = 0
        if(mantissa == 25'b0) begin
            exponent_norm = 8'b0;
            mantissa_norm = 22'b0;
        end

        //Case 2: Carry-out after addition
        else if(mantissa[24]) begin
            //shift right 1 bit, take mantissa from 10.xxxx to 1.xxxx
            mantissa_norm = mantissa[22:0];//remove bit[0]
            // Right shift by one to restore normalized form (10.x -> 1.0x),
            // therefore increment the exponent by one.
            exponent_norm = (exponent < 8'hFF) ? exponent + 1'b1 : 8'hFF;
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