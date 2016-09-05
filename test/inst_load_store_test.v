`timescale 1ns/1ps
`include "assert.v"

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

        $readmemh("../data/inst_load_store_test.txt", top.rom.memory, 0, 31);

        clk = 0;
        rst = 1;
        #20 rst = 0;
        #10 `AR(1,32'hxxxxxxxx);`AR(3,32'h0000EEFF);
        #2  `AR(1,32'hxxxxxxxx);`AR(3,32'h0000EEFF);
        #2  `AR(1,32'hxxxxxxxx);`AR(3,32'h000000EE);
        #2  `AR(1,32'hxxxxxxxx);`AR(3,32'h000000EE);
        #2  `AR(1,32'hxxxxxxxx);`AR(3,32'h0000CCDD);
        #2  `AR(1,32'hxxxxxxxx);`AR(3,32'h0000CCDD);
        #2  `AR(1,32'hxxxxxxxx);`AR(3,32'h000000CC);
        #2  `AR(1,32'hxxxxxxxx);`AR(3,32'h000000CC);
        #2  `AR(1,32'hFFFFFFFF);`AR(3,32'h000000CC);
        #2  `AR(1,32'h000000EE);`AR(3,32'h000000CC);
        #2  `AR(1,32'h000000EE);`AR(3,32'h0000AABB);
        #2  `AR(1,32'h000000EE);`AR(3,32'h0000AABB);
        #2  `AR(1,32'h0000AABB);`AR(3,32'h0000AABB);
        #2  `AR(1,32'hFFFFAABB);`AR(3,32'h0000AABB);
        #2  `AR(1,32'hFFFFAABB);`AR(3,32'h00008899);
        #2  `AR(1,32'hFFFFAABB);`AR(3,32'h00008899);
        #2  `AR(1,32'hFFFF8899);`AR(3,32'h00008899);
        #2  `AR(1,32'h00008899);`AR(3,32'h00008899);
        #2  `AR(1,32'h00008899);`AR(3,32'h00004455);
        #2  `AR(1,32'h00008899);`AR(3,32'h44550000);
        #2  `AR(1,32'h00008899);`AR(3,32'h44556677);
        #2  `AR(1,32'h00008899);`AR(3,32'h44556677);
        #2  `AR(1,32'h44556677);`AR(3,32'h44556677);
        #2  `AR(1,32'h44556677);`AR(3,32'h44556677);
        #2  `AR(1,32'hBB889977);`AR(3,32'h44556677);
        #2  `AR(1,32'hBB889977);`AR(3,32'h44556677);
        #2  `AR(1,32'hBB889944);`AR(3,32'h44556677);
        #2  `AR(1,32'hBB889944);`AR(3,32'h44556677);
        #2  `AR(1,32'hBB889944);`AR(3,32'h44556677);
        #2  `AR(1,32'hBB889944);`AR(3,32'h44556677);
        #2  `AR(1,32'h889944FF);`AR(3,32'h44556677);
        #2  `AR(1,32'hAABB88BB);`AR(3,32'h44556677);
        `PASS;
    end

endmodule