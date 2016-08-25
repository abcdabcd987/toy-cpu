module reg_pc (
    output reg [31:0] pc ,
    output reg        ce ,
    input             clk,
    input             rst
);

    always @(posedge clk) begin
        ce <= ~rst;
        pc <= rst ? 0 : pc + 4;
    end

endmodule // reg_pc