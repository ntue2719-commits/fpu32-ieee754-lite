module mantissa_multiply(
    input [22:0] fraction_A,
    input [22:0] fraction_B,

    output [47:0] mantissa_product
);

wire [23:0] mantissa_A;
wire [23:0] mantissa_B;

assign mantissa_A = {1'b1, fraction_A};
assign mantissa_B = {1'b1, fraction_B};

assign mantissa_product = mantissa_A * mantissa_B;

endmodule