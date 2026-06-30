module floating_compare (
    input  [31:0] a,
    input  [31:0] b,
    output reg    result
);

wire a_is_nan  = (&a[30:23]) && (|a[22:0]);
wire b_is_nan  = (&b[30:23]) && (|b[22:0]);

wire a_is_zero = (a[30:0] == 31'd0);
wire b_is_zero = (b[30:0] == 31'd0);

always @(*) begin

    // Default
    result = 1'b0;

    // NaN: every comparison (except !=) is false
    if (a_is_nan || b_is_nan) begin
        result = 1'b0;
    end

    // +0 and -0 are equal  
    else if (a_is_zero && b_is_zero) begin
        result = 1'b1;
    end
    // Bitwise identical
    else if (a == b) begin
        result = 1'b1;
    end  
    // Different signs
    else if (a[31] != b[31]) begin
        result = ~a[31];
    end
    // Same sign: positive numbers
    else if (a[31] == 1'b0) begin

        if (a[30:23] != b[30:23])
            result = (a[30:23] > b[30:23]);
        else
            result = (a[22:0] > b[22:0]);

    end
    // Same sign: negative numbers
    else begin

        if (a[30:23] != b[30:23])
            result = (a[30:23] < b[30:23]);
        else
            result = (a[22:0] < b[22:0]);

    end

end

endmodule