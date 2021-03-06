module reg_pc (
    output reg [31:0] pc     ,
    output reg        ce     ,
    input      [ 5:0] stall  ,
    input             br     ,
    input      [31:0] br_addr,
    input             clk    ,
    input             rst
);

    always @(posedge clk) begin
        if (rst) begin
            ce <= 0;
            pc <= 0;
        end else begin
            ce <= 1;
            if (!stall) begin
                if (br) pc <= br_addr;
                else pc <= pc + 4;
            end
        end
    end

endmodule // reg_pc