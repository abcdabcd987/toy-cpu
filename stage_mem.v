module stage_mem (
    input             we       ,
    input      [ 4:0] waddr    ,
    input      [31:0] wdata    ,
    output reg        we_o     ,
    output reg [ 4:0] waddr_o  ,
    output reg [31:0] wdata_o  ,
    input             we_hilo  ,
    input      [31:0] hi       ,
    input      [31:0] lo       ,
    output reg        we_hilo_o,
    output reg [31:0] hi_o     ,
    output reg [31:0] lo_o     ,
    input             rst
);

    always @* begin
        if (rst) begin
            we_o      <= 0;
            waddr_o   <= 0;
            wdata_o   <= 0;
            we_hilo_o <= 0;
            hi_o      <= 0;
            lo_o      <= 0;
        end else begin
            we_o      <= we;
            waddr_o   <= waddr;
            wdata_o   <= wdata;
            we_hilo_o <= we_hilo;
            hi_o      <= hi;
            lo_o      <= lo;
        end
    end

endmodule // stage_mem
