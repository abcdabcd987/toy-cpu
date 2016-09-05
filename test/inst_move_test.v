`timescale 1ns/1ps
`include "assert.v"

module inst_move_test();
    reg     clk, rst;
    integer i  ;

    top top (clk,rst);

    always #1 clk = ~clk;
    initial begin
        $dumpfile("inst_move_test.vcd");
        $dumpvars;
        for (i = 1; i <= 4; i = i+1)
            $dumpvars(0, top.openmips.regfile.regs[i]);

        $readmemh("../data/inst_move_test.txt", top.rom.memory, 0, 15);

        clk = 0;
        rst = 1;
        #20 rst = 0;
        #10 `AR(1,32'h00000000);`AR(2,32'hxxxxxxxx);`AR(3,32'hxxxxxxxx);`AR(4,32'hxxxxxxxx);`AHI(32'h00000000);`ALO(32'h00000000);
        #2  `AR(1,32'h00000000);`AR(2,32'hFFFF0000);`AR(3,32'hxxxxxxxx);`AR(4,32'hxxxxxxxx);`AHI(32'h00000000);`ALO(32'h00000000);
        #2  `AR(1,32'h00000000);`AR(2,32'hFFFF0000);`AR(3,32'h05050000);`AR(4,32'hxxxxxxxx);`AHI(32'h00000000);`ALO(32'h00000000);
        #2  `AR(1,32'h00000000);`AR(2,32'hFFFF0000);`AR(3,32'h05050000);`AR(4,32'h00000000);`AHI(32'h00000000);`ALO(32'h00000000);
        #2  `AR(1,32'h00000000);`AR(2,32'hFFFF0000);`AR(3,32'h05050000);`AR(4,32'hFFFF0000);`AHI(32'h00000000);`ALO(32'h00000000);
        #2  `AR(1,32'h00000000);`AR(2,32'hFFFF0000);`AR(3,32'h05050000);`AR(4,32'hFFFF0000);`AHI(32'h00000000);`ALO(32'h00000000);
        #2  `AR(1,32'h00000000);`AR(2,32'hFFFF0000);`AR(3,32'h05050000);`AR(4,32'h05050000);`AHI(32'h00000000);`ALO(32'h00000000);
        #2  `AR(1,32'h00000000);`AR(2,32'hFFFF0000);`AR(3,32'h05050000);`AR(4,32'h05050000);`AHI(32'h00000000);`ALO(32'h00000000);
        #2  `AR(1,32'h00000000);`AR(2,32'hFFFF0000);`AR(3,32'h05050000);`AR(4,32'h05050000);`AHI(32'h00000000);`ALO(32'h00000000);
        #2  `AR(1,32'h00000000);`AR(2,32'hFFFF0000);`AR(3,32'h05050000);`AR(4,32'h05050000);`AHI(32'hFFFF0000);`ALO(32'h00000000);
        #2  `AR(1,32'h00000000);`AR(2,32'hFFFF0000);`AR(3,32'h05050000);`AR(4,32'h05050000);`AHI(32'h05050000);`ALO(32'h00000000);
        #2  `AR(1,32'h00000000);`AR(2,32'hFFFF0000);`AR(3,32'h05050000);`AR(4,32'h05050000);`AHI(32'h05050000);`ALO(32'h00000000);
        #2  `AR(1,32'h00000000);`AR(2,32'hFFFF0000);`AR(3,32'h05050000);`AR(4,32'h05050000);`AHI(32'h05050000);`ALO(32'h05050000);
        #2  `AR(1,32'h00000000);`AR(2,32'hFFFF0000);`AR(3,32'h05050000);`AR(4,32'h05050000);`AHI(32'h05050000);`ALO(32'hFFFF0000);
        #2  `AR(1,32'h00000000);`AR(2,32'hFFFF0000);`AR(3,32'h05050000);`AR(4,32'h05050000);`AHI(32'h05050000);`ALO(32'h00000000);
        #2  `AR(1,32'h00000000);`AR(2,32'hFFFF0000);`AR(3,32'h05050000);`AR(4,32'h00000000);`AHI(32'h05050000);`ALO(32'h00000000);
        `PASS;
    end

endmodule