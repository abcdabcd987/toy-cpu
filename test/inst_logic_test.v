`timescale 1ns/1ps

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

        $readmemh("../data/inst_logic.txt", top.rom.memory, 0, 8);

        clk = 0;
        rst = 1;
        #20 rst = 0;
        #200 $finish;
    end

endmodule