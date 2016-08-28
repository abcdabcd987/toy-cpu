`timescale 1ns/1ps

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

        $readmemh("../data/inst_shift.txt", top.ram.memory, 0, 15);

        clk = 0;
        rst = 1;
        #20 rst = 0;
        #200 $finish;
    end

endmodule