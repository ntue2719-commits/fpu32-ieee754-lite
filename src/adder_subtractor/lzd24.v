
// Module : lzd24
// Tuan 2 : Leading Zero Detector cho 24-bit
// Chuc nang: dem so bit 0 lien tiep tu MSB (bit 23) xuong, dung de
//            biet can shift trai bao nhieu bit khi chuan hoa lai
//            ket qua phep tru (truong hop trieu tieu - cancellation).
// Vi du: in = 24'b000000000000000000000001 -> count = 23


module lzd24 (
    input  wire [23:0] in,
    output reg  [4:0]  count   // 0..24
);

    integer i;
    reg found;

    always @(*) begin
        count = 5'd24;
        found = 1'b0;
        for (i = 23; i >= 0; i = i - 1) begin
            if (!found && in[i]) begin
                count = 23 - i;
                found = 1'b1;
            end
        end
    end

endmodule
