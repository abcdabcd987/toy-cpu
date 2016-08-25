module reg_mem_wb (
    input             mem_we   ,
    input      [ 4:0] mem_waddr,
    input      [31:0] mem_wdata,
    output reg        wb_we    ,
    output reg [ 4:0] wb_waddr ,
    output reg [31:0] wb_wdata ,
    input             clk      ,
    input             rst
);

    always @(posedge clk) begin
        if (rst) begin
            wb_we    <= 0;
            wb_waddr <= 0;
            wb_wdata <= 0;
        end else begin
            wb_we    <= mem_we;
            wb_waddr <= mem_waddr;
            wb_wdata <= mem_wdata;
        end
    end

endmodule // reg_mem_wb
