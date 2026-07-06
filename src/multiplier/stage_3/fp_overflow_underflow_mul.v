module overflow_underflow(
    input  [8:0] exponent_in,
    input  [22:0] fraction_in,

    output reg [7:0] exponent_out,
    output reg [22:0] fraction_out,

    output reg overflow,
    output reg underflow
);

always @(*) begin

    // Gia tri binh thuong
    overflow     = 1'b0;
    underflow    = 1'b0;
    exponent_out = exponent_in[7:0];
    fraction_out = fraction_in;

    // Overflow
    if(exponent_in >= 9'd255) begin

        overflow     = 1'b1;

        exponent_out = 8'hFF;
        fraction_out = 23'd0;

    end

    // Underflow 
    else if(exponent_in <= 9'd0) begin

        underflow    = 1'b1;

        exponent_out = 8'd0;
        fraction_out = 23'd0;

    end

end

endmodule