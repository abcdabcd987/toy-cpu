`timescale 1ns/1ps

module inst_jump_test();
    reg     clk, rst;
    integer i  ;

    top top (clk,rst);

    always #1 clk = ~clk;
    initial begin
        $dumpfile("inst_jump_test.vcd");
        $dumpvars;
        $dumpvars(0, top.openmips.regfile.regs[1]);
        $dumpvars(0, top.openmips.regfile.regs[2]);
        $dumpvars(0, top.openmips.regfile.regs[31]);

        $readmemh("../data/inst_jump.txt", top.rom.memory, 0, 34);

        clk = 0;
        rst = 1;
        #20 rst = 0;
        #200 $finish;
    end

endmodule