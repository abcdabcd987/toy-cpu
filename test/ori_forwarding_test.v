`timescale 1ns/1ps
`include "assert.v"

module ori_forwarding_test();
    reg     clk, rst;
    integer i  ;

    top top (clk,rst);

    always #1 clk = ~clk;
    initial begin
        $dumpfile("ori_forwarding_test.vcd");
        $dumpvars;
        for (i = 2; i <= 5; i = i+1)
            $dumpvars(0, top.openmips.regfile.regs[i]);

        $readmemh("../data/ori_forwarding_test.txt", top.rom.memory, 0, 6);

        clk = 0;
        rst = 1;
        #20 rst = 0;
        #16 `AR(5, 32'h00001100);
        #2  `AR(5, 32'h00001120);
        #2  `AR(5, 32'h00005520);
        #2  `AR(5, 32'h00005564);
        `PASS;
    end

endmodule