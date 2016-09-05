`timescale 1ns/1ps
`include "assert.v"

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

        $readmemh("../data/inst_jump_test.txt", top.rom.memory, 0, 34);

        clk = 0;
        rst = 1;
        #20 rst = 0;
        #10 `AR(1,32'h00000001);`AR(31,32'hxxxxxxxx);`AHI(32'h00000000);`ALO(32'h00000000);
        #2  `AR(1,32'h00000001);`AR(31,32'hxxxxxxxx);`AHI(32'h00000000);`ALO(32'h00000000);
        #2  `AR(1,32'h00000002);`AR(31,32'hxxxxxxxx);`AHI(32'h00000000);`ALO(32'h00000000);
        #2  `AR(1,32'h00000003);`AR(31,32'hxxxxxxxx);`AHI(32'h00000000);`ALO(32'h00000000);
        #2  `AR(1,32'h00000003);`AR(31,32'h0000002C);`AHI(32'h00000000);`ALO(32'h00000000);
        #2  `AR(1,32'h00000003);`AR(31,32'h0000002C);`AHI(32'h00000002);`ALO(32'h0000000E);
        #2  `AR(1,32'h00000003);`AR(31,32'h0000002C);`AHI(32'h00000002);`ALO(32'h0000000E);
        #2  `AR(1,32'h00000048);`AR(31,32'h0000002C);`AHI(32'h00000002);`ALO(32'h0000000E);
        #2  `AR(1,32'h00000005);`AR(31,32'h0000002C);`AHI(32'h00000002);`ALO(32'h0000000E);
        #2  `AR(1,32'h00000006);`AR(31,32'h0000002C);`AHI(32'h00000002);`ALO(32'h0000000E);
        #2  `AR(1,32'h00000006);`AR(31,32'h0000002C);`AHI(32'h00000002);`ALO(32'h0000000E);
        #2  `AR(1,32'h00000006);`AR(31,32'h0000002C);`AHI(32'h00000002);`ALO(32'h0000000E);
        #2  `AR(1,32'h00000007);`AR(31,32'h0000002C);`AHI(32'h00000002);`ALO(32'h0000000E);
        #2  `AR(1,32'h00000007);`AR(31,32'h0000002C);`AHI(32'h00000002);`ALO(32'h0000000E);
        #2  `AR(1,32'h00000008);`AR(31,32'h0000002C);`AHI(32'h00000002);`ALO(32'h0000000E);
        #2  `AR(1,32'h00000009);`AR(31,32'h0000002C);`AHI(32'h00000002);`ALO(32'h0000000E);
        #2  `AR(1,32'h0000000A);`AR(31,32'h0000002C);`AHI(32'h00000002);`ALO(32'h0000000E);
        `PASS;
    end

endmodule