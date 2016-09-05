module top (
    input clk,
    input rst
);

    wire [31:0] addr, inst, ram_data_i, ram_data_o, ram_addr;
    wire [ 3:0] ram_sel;
    wire        ce, ram_we, ram_ce;

    openmips openmips (
        .rom_data  (inst      ),
        .rom_addr  (addr      ),
        .rom_ce    (ce        ),
        .ram_data  (ram_data_o),
        .ram_addr  (ram_addr  ),
        .ram_we    (ram_we    ),
        .ram_sel   (ram_sel   ),
        .ram_data_o(ram_data_i),
        .ram_ce    (ram_ce    ),
        .clk       (clk       ),
        .rst       (rst       )
    );

    rom rom (
        .data_out(inst),
        .addr    (addr),
        .data_in (    ),
        .we      (1'b0),
        .clk     (clk )
    );

    ram ram (
        .ce    (ram_ce    ),
        .we    (ram_we    ),
        .addr  (ram_addr  ),
        .sel   (ram_sel   ),
        .data_i(ram_data_i),
        .data_o(ram_data_o),
        .clk   (clk       )
    );

endmodule // top