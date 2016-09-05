`timescale 1ns/1ps
`include "assert.v"

module inst_shift_test();
    reg     clk, rst;
    integer i  ;

    top top (clk,rst);

    always #1 clk = ~clk;
    initial begin
        $dumpfile("inst_shift_test.vcd");
        $dumpvars;
        $dumpvars(0, top.openmips.regfile.regs[2]);
        $dumpvars(0, top.openmips.regfile.regs[5]);
        $dumpvars(0, top.openmips.regfile.regs[7]);
        $dumpvars(0, top.openmips.regfile.regs[8]);

        $readmemh("../data/inst_shift_test.txt", top.rom.memory, 0, 15);

        clk = 0;
        rst = 1;
        #20 rst = 0;
        #10 `AR(2, 32'h04040000);
        #2  `AR(2, 32'h04040404);
        #2  `AR(7, 32'h00000007);
        #2  `AR(5, 32'h00000005);
        #2  `AR(8, 32'h00000008);
        #2  `AR(2, 32'h04040404); `AR(7, 32'h00000007); `AR(5, 32'h00000005); `AR(8, 32'h00000008);
        #2  `AR(2, 32'h04040400);
        #2  `AR(2, 32'h02020000);
        #2  `AR(2, 32'h00020200);
        #2  `AR(2, 32'h00001010);
        #2  `AR(2, 32'h00001010);
        #2  `AR(2, 32'h00001010); `AR(7, 32'h00000007); `AR(5, 32'h00000005); `AR(8, 32'h00000008);
        #2  `AR(2, 32'h80800000);
        #2  `AR(2, 32'h80800000);
        #2  `AR(2, 32'hffff8080);
        #2  `AR(2, 32'hffffff80);
        `PASS;
    end

endmodule