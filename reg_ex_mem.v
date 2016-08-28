module reg_ex_mem (
    input             ex_we      ,
    input      [ 4:0] ex_waddr   ,
    input      [31:0] ex_wdata   ,
    output reg        mem_we     ,
    output reg [ 4:0] mem_waddr  ,
    output reg [31:0] mem_wdata  ,
    input             ex_we_hilo ,
    input      [31:0] ex_hi      ,
    input      [31:0] ex_lo      ,
    output reg        mem_we_hilo,
    output reg [31:0] mem_hi     ,
    output reg [31:0] mem_lo     ,
    input             clk        ,
    input             rst
);

    always @(posedge clk) begin
        if (rst) begin
            mem_we      <= 0;
            mem_waddr   <= 0;
            mem_wdata   <= 0;
            mem_we_hilo <= 0;
            mem_hi      <= 0;
            mem_lo      <= 0;
        end else begin
            mem_we      <= ex_we;
            mem_waddr   <= ex_waddr;
            mem_wdata   <= ex_wdata;
            mem_we_hilo <= ex_we_hilo;
            mem_hi      <= ex_hi;
            mem_lo      <= ex_lo;
        end
    end

endmodule // reg_ex_mem
