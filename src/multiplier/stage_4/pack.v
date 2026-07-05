module pack(
    input sign,
    input [7:0] exponent,
    input [22:0] fraction,

    output [31:0] result
);

assign result = {sign,exponent,fraction};

endmodule