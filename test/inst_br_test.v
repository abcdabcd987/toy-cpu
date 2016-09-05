`timescale 1ns/1ps

module inst_br_test();
    reg     clk, rst;
    integer i  ;

    top top (clk,rst);

    always #1 clk = ~clk;
    initial begin
        $dumpfile("inst_br_test.vcd");
        $dumpvars;
        $dumpvars(0, top.openmips.regfile.regs[1]);
        $dumpvars(0, top.openmips.regfile.regs[3]);
        $dumpvars(0, top.openmips.regfile.regs[31]);

        $readmemh("../data/inst_br.txt", top.rom.memory, 0, 91);

        clk = 0;
        rst = 1;
        #20 rst = 0;
        #200 $finish;
    end

endmodule