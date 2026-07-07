module fp_lzd(
    input [23:0] mantissa,
    output [4:0] count_zero
);

    assign count_zero = (mantissa[23]) ? 5'd0 : (mantissa[22]) ? 5'd1 :
                        (mantissa[21]) ? 5'd2 : (mantissa[20]) ? 5'd3 :
                        (mantissa[19]) ? 5'd4 : (mantissa[18]) ? 5'd5 :
                        (mantissa[17]) ? 5'd6 : (mantissa[16]) ? 5'd7 :
                        (mantissa[15]) ? 5'd8 : (mantissa[14]) ? 5'd9 :
                        (mantissa[13]) ? 5'd10 : (mantissa[12]) ? 5'd11 :
                        (mantissa[11]) ? 5'd12 : (mantissa[10]) ? 5'd13 :
                        (mantissa[9]) ? 5'd14 : (mantissa[8]) ? 5'd15 :
                        (mantissa[7]) ? 5'd16 : (mantissa[6]) ? 5'd17 :
                        (mantissa[5]) ? 5'd18 : (mantissa[4]) ? 5'd19 :
                        (mantissa[3]) ? 5'd20 : (mantissa[2]) ? 5'd21 :
                        (mantissa[1]) ? 5'd22 : (mantissa[0]) ? 5'd23 : 5'd24;
                        
endmodule