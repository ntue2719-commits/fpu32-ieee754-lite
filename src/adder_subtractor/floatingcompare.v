module floatingcompare (
        input [31:0] a,
        input [31:0] b,
        output reg result
);


always @ (*) begin

        //compare sign
        if (a[31] != b[31]) begin
                result = ~a[31];
        end
        //compare exponent if sign equal
        else if(a[30:23] != b[30:23]) begin
                result = (a[30:23] > b[30:23]) ? 1'b1 : 1'b0;
                if(a[31]) result = ~ result;//same negative so the bigger exponent is the smaller number
        end
        //compare mantissa if sign and exponent are equal
        else if((a[22:0] != b[22:0])) begin
                result = (a[22:0] >  b[22:0]) ? 1'b1: 1'b0;
                if(a[31]) result = ~ result;
        end
        else begin
                result = 1'b1; //a == b
        end
end

endmodule