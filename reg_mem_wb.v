module reg_mem_wb (
    input             mem_we     ,
    input      [ 4:0] mem_waddr  ,
    input      [31:0] mem_wdata  ,
    output reg        wb_we      ,
    output reg [ 4:0] wb_waddr   ,
    output reg [31:0] wb_wdata   ,
    input             mem_we_hilo,
    input      [31:0] mem_hi     ,
    input      [31:0] mem_lo     ,
    output reg        wb_we_hilo ,
    output reg [31:0] wb_hi      ,
    output reg [31:0] wb_lo      ,
    input             clk        ,
    input             rst
);

    always @(posedge clk) begin
        if (rst) begin
            wb_we      <= 0;
            wb_waddr   <= 0;
            wb_wdata   <= 0;
            wb_we_hilo <= 0;
            wb_hi      <= 0;
            wb_lo      <= 0;
        end else begin
            wb_we      <= mem_we;
            wb_waddr   <= mem_waddr;
            wb_wdata   <= mem_wdata;
            wb_we_hilo <= mem_we_hilo;
            wb_hi      <= mem_hi;
            wb_lo      <= mem_lo;
        end
    end

endmodule // reg_mem_wb
