module regfile_test();

    reg [31:0] wdata, rdata1, rdata2;
    reg [ 4:0] waddr, raddr1, raddr2;
    reg        we, re1, re2, clk, rst;

    regfile regfile (
        we, waddr, wdata,
        re1, raddr1, rdata1,
        re2, raddr2, rdata2,
        clk, rst
    );

    always #1 clk = ~clk;

    initial begin
        clk = 0; rst = 0; we = 0; re1 = 1; re2 = 1;
        @(posedge clk); @(negedge clk);

        wdata = 123456; waddr = 19; we = 1;
        @(posedge clk); @(negedge clk);

        wdata = 654321; waddr = 23; we = 1;
        @(posedge clk); @(negedge clk);

        we = 0; raddr1 = 19; raddr2 = 23;
        @(posedge clk); @(negedge clk);
        $display("rdata1=%d, rdata2=%d", rdata1, rdata2);

        wdata = 233; waddr = 19; we = 1;
        @(posedge clk); @(negedge clk);
        $display("rdata1=%d, rdata2=%d", rdata1, rdata2);

        $finish;
    end

endmodule // regfile_test