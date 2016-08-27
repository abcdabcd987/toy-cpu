module top (
    input clk,
    input rst
);

    wire [31:0] addr, inst;
    wire        ce  ;

    openmips openmips (
        .ram_data(inst),
        .ram_addr(addr),
        .ram_ce  (ce  ),
        .clk     (clk ),
        .rst     (rst )
    );

    memory ram (
        .data_out(inst),
        .addr    (addr),
        .data_in (    ),
        .we      (1'b0),
        .clk     (clk )
    );

endmodule // top