module stage_mem (
    input             we     ,
    input      [ 4:0] waddr  ,
    input      [31:0] wdata  ,
    output reg        we_o   ,
    output reg [ 4:0] waddr_o,
    output reg [31:0] wdata_o,
    input             rst
);

    always @* begin
        if (rst) begin
            we_o    <= 0;
            waddr_o <= 0;
            wdata_o <= 0;
        end else begin
            we_o    <= we;
            waddr_o <= waddr;
            wdata_o <= wdata;
        end
    end

endmodule // stage_mem
