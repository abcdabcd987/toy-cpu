`timescale 1ns/1ps

module ori_test();
    reg     clk, rst;
    integer i  ;

    top top (clk,rst);

    always #1 clk = ~clk;
    initial begin
        $dumpfile("ori_test.vcd");
        $dumpvars(0, ori_test);
        for (i = 2; i <= 5; i = i+1)
            $dumpvars(0, top.openmips.regfile.regs[i]);

        $readmemh("../data/ori.txt", top.ram.memory, 0, 3);

        clk = 0;
        rst = 1;
        #20 rst = 0;
        #200 $finish;
    end

endmodule