module ALU (
    output reg [7:0] s,
    input [7:0] a, b,
    input [2:0] op
);

    always @(*) begin
        /* three bits, so the range of bench is 0 ~ 7 */
        case(op)
        3'h0:s = a + b;
        3'h1:s = a - b;
        3'h2:s = a & b;
        3'h3:s = a | b;
        3'h4:s = a ^ b;
        3'h5:s = ~a;
        3'h6:s = ~b;
        3'h7:s = 0;
        endcase
    end
endmodule