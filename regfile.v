module regfile (
    input      [ 4:0] waddr ,
    input      [31:0] wdata ,
    input             we    ,
    input re1,
    input      [ 4:0] raddr1,
    output reg [31:0] rdata1,
    input re2,
    input      [ 4:0] raddr2,
    output reg [31:0] rdata2,
    input             clk   ,
    input             rst
);

    reg [31:0] regs[0:31];

    always @(posedge clk) begin
        if (!rst && we && waddr != 0) begin
            regs[waddr] <= wdata;
        end
    end

    always @* begin
        if (rst || raddr1 == 0 || !re1) begin
            rdata1 <= 0;
        end else if (we && waddr == raddr1) begin
            rdata1 <= wdata;
        end else begin
            rdata1 <= regs[raddr1];
        end
    end

    always @* begin
        if (rst || raddr2 == 0 || !re2) begin
            rdata2 <= 0;
        end else if (we && waddr == raddr2) begin
            rdata2 <= wdata;
        end else begin
            rdata2 <= regs[raddr2];
        end
    end

endmodule // regfile