module unpack(
    input [31:0] in,

    output sign,
    output [7:0] exponent,
    output [22:0] fraction
);

assign sign = in[31];
assign exponent = in[30:23];
assign fraction = in[22:0];

endmodule