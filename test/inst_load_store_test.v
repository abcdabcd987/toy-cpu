`timescale 1ns/1ps

module inst_load_store_test();
    reg     clk, rst;
    integer i  ;

    top top (clk,rst);

    always #1 clk = ~clk;
    wire [31:0] mem0x0000 = {top.ram.bank3[0], top.ram.bank2[0], top.ram.bank1[0], top.ram.bank0[0]};
    wire [31:0] mem0x0004 = {top.ram.bank3[1], top.ram.bank2[1], top.ram.bank1[1], top.ram.bank0[1]};
    wire [31:0] mem0x0008 = {top.ram.bank3[2], top.ram.bank2[2], top.ram.bank1[2], top.ram.bank0[2]};
    initial begin
        $dumpfile("inst_load_store_test.vcd");
        $dumpvars;
        $dumpvars(0, top.openmips.regfile.regs[1]);
        $dumpvars(0, top.openmips.regfile.regs[3]);

        $readmemh("../data/inst_load_store.txt", top.rom.memory, 0, 31);

        clk = 0;
        rst = 1;
        #20 rst = 0;
        #200 $finish;
    end

endmodule