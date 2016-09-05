module reg_hilo (
    output reg [31:0] hi_o,
    output reg [31:0] lo_o,
    input             we  ,
    input      [31:0] hi_i,
    input      [31:0] lo_i,
    input             clk ,
    input             rst
);

    always @(posedge clk) begin
        if (rst) begin
            hi_o <= 0;
            lo_o <= 0;
        end else if (we) begin
            hi_o <= hi_i;
            lo_o <= lo_i;
        end
    end

endmodule // reg_hilo