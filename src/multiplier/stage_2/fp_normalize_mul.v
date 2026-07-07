module fp_normalize_mul(
    input [47:0] mantissa_product,
    input signed [9:0] exponent_product,

    output reg [22:0] fraction_out,
    output reg [7:0] exponent_out,

    output reg overflow,
    output reg underflow
);

reg signed [9:0] exponent_temp;
reg [22:0] fraction_temp;

always @(*) begin
    // Normalize
    if(mantissa_product[47]) begin //TH1: 10.xxx hoac 11.xxx
        exponent_temp = exponent_product + 1;
        fraction_temp = mantissa_product[46:24];
    end

    else begin //TH2: 1.xxx
        exponent_temp = exponent_product;
        fraction_temp = mantissa_product[45:23];
    end

    // Default
    overflow  = 1'b0;
    underflow = 1'b0;

    // Overflow
    if(exponent_temp > 10'sd254) begin
        overflow = 1'b1;

        exponent_out = 8'hFF;
        fraction_out = 23'd0;
    end

    // Underflow
    else if(exponent_temp <= 10'sd0) begin
        underflow = 1'b1;

        exponent_out = 8'd0;
        fraction_out = 23'd0;
    end

    // Normal
    else begin
        exponent_out = exponent_temp[7:0];
        fraction_out = fraction_temp;
    end
end

endmodule