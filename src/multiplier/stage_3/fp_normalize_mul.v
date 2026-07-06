module normalize(
    input [47:0] mantissa_product,
    input [8:0] exponent_product,

    output reg [22:0] fraction_out,
    output reg [8:0] exponent_out
);

always @(*) begin

    if (mantissa_product[47]) // TH1: 10.xxxx hoac 11.xxxx
    begin
        exponent_out  = exponent_product + 1;
        fraction_out = mantissa_product[46:24];
    end

    else // TH2: 1.xxxx
    begin
        exponent_out  = exponent_product;
        fraction_out = mantissa_product[45:23];
    end
end

endmodule