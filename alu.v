module alu (
    input      [31:0] a, b,
    input      [ 3:0] aluc,
    output reg [31:0] res
);

    always @* begin
        case (aluc)
            4'b0000 : res <= a & b;
            4'b0001 : res <= a | b;
            4'b0010 : res <= a ^ b;

            4'b0100 : res <= a << b;
            4'b0101 : res <= a >> b;
            4'b0110 : res <= a >>> b;

            4'b1000 : res <= a + b;
            4'b1001 : res <= a - b;
            4'b1010 : res <= a * b;
            4'b1011 : res <= a / b;
        endcase
    end

endmodule // alu
