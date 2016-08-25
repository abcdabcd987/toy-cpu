module reg_if_id (
    input      [31:0] if_pc  ,
    input      [31:0] if_inst,
    output reg [31:0] id_pc  ,
    output reg [31:0] id_inst,
    input             clk    ,
    input             rst
);

    always @(posedge clk) begin
        if (rst) begin
            id_pc   <= 0;
            id_inst <= 0;
        end else begin
            id_pc   <= if_pc;
            id_inst <= if_inst;
        end
    end

endmodule // reg_if_id