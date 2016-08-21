module alu_test();

    reg [31:0] a, b, res;
    reg [ 3:0] aluc;

    alu alu (a,b,aluc,res);

    initial begin
        a = 145826;
        b = 59403;
        aluc = 4'b0000;
        #1 $display("%d & %d = %d", a, b, res);
        aluc = 4'b0001;
        #1 $display("%d | %d = %d", a, b, res);
        aluc = 4'b0010;
        #1 $display("%d ^ %d = %d", a, b, res);
        aluc = 4'b1000;
        #1 $display("%d + %d = %d", a, b, res);
        aluc = 4'b1001;
        #1 $display("%d - %d = %d", a, b, res);
        aluc = 4'b1010;
        #1 $display("%d * %d = %d", a, b, res);
        aluc = 4'b1011;
        #1 $display("%d / %d = %d", a, b, res);

        a = 145826;
        b = 2;
        aluc = 4'b0100;
        #1 $display("%d <<%d = %d", a, b, res);
        aluc = 4'b0101;
        #1 $display("%d >>%d = %d", a, b, res);
        aluc = 4'b0110;
        #1 $display("%d>>>%d = %d", a, b, res);

        $finish;
    end

endmodule // alu_test