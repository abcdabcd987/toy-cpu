`timescale 1ns/1ps
`include "assert.v"

module inst_logic_test();
    reg     clk, rst;
    integer i  ;

    top top (clk,rst);

    always #1 clk = ~clk;
    initial begin
        $dumpfile("inst_logic_test.vcd");
        $dumpvars;
        for (i = 1; i <= 4; i = i+1)
            $dumpvars(0, top.openmips.regfile.regs[i]);

        $readmemh("../data/inst_logic_test.txt", top.rom.memory, 0, 8);

        clk = 0;
        rst = 1;
        #20 rst = 0;
        #10 `AR(1, 32'h01010000); `AR(2, 32'hxxxxxxxx); `AR(3, 32'hxxxxxxxx); `AR(4, 32'hxxxxxxxx);
        #2  `AR(1, 32'h01010101); `AR(2, 32'hxxxxxxxx); `AR(3, 32'hxxxxxxxx); `AR(4, 32'hxxxxxxxx);
        #2  `AR(1, 32'h01010101); `AR(2, 32'h01011101); `AR(3, 32'hxxxxxxxx); `AR(4, 32'hxxxxxxxx);
        #2  `AR(1, 32'h01011101); `AR(2, 32'h01011101); `AR(3, 32'hxxxxxxxx); `AR(4, 32'hxxxxxxxx);
        #2  `AR(1, 32'h01011101); `AR(2, 32'h01011101); `AR(3, 32'h00000000); `AR(4, 32'hxxxxxxxx);
        #2  `AR(1, 32'h00000000); `AR(2, 32'h01011101); `AR(3, 32'h00000000); `AR(4, 32'hxxxxxxxx);
        #2  `AR(1, 32'h00000000); `AR(2, 32'h01011101); `AR(3, 32'h00000000); `AR(4, 32'h0000FF00);
        #2  `AR(1, 32'h0000FF00); `AR(2, 32'h01011101); `AR(3, 32'h00000000); `AR(4, 32'h0000FF00);
        #2  `AR(1, 32'hFFFF00FF); `AR(2, 32'h01011101); `AR(3, 32'h00000000); `AR(4, 32'h0000FF00);
        `PASS;
    end

endmodule