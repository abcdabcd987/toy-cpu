module memory_test();
    reg [31:0] data_out, data_in, addr;
    reg        we, clk;

    memory memory (data_out,addr,data_in,we,clk);
    always #1 clk = ~clk;

    initial begin
        integer f, x, c, i;
        clk = 0;
        f = $fopen("../data/data1.txt", "r");
        we = 1;
        for (c = 0; !$feof(f); c = c + 1) begin
            $fscanf(f, "%x", x);
            data_in = x;
            addr = c << 2;
            @(posedge clk);
            #1;
        end
        $fclose(f);

        we = 0;
        for (i = 0; i < c; i = i + 1) begin
            addr = i<<2;
            #1;
            $display("MEM[%x]=%x", addr, data_out);
        end

        $finish;
    end

endmodule // memory_test