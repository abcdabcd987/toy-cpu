module reg_ex_mem (
    input             ex_we    ,
    input      [ 4:0] ex_waddr ,
    input      [31:0] ex_wdata ,
    output reg        mem_we   ,
    output reg [ 4:0] mem_waddr,
    output reg [31:0] mem_wdata,
    input             clk      ,
    input             rst
);

    always @(posedge clk) begin
        if (rst) begin
            mem_we    <= 0;
            mem_waddr <= 0;
            mem_wdata <= 0;
        end else begin
            mem_we    <= ex_we;
            mem_waddr <= ex_waddr;
            mem_wdata <= ex_wdata;
        end
    end

endmodule // reg_ex_mem
