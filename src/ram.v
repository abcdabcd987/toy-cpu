module ram (
    input  wire        ce    ,
    input  wire        we    ,
    input  wire [31:0] addr  ,
    input  wire [ 3:0] sel   ,
    input  wire [31:0] data_i,
    output reg  [31:0] data_o,
    input  wire        clk
);
    localparam MemNum = 1024;
    localparam MemLog = 10;

    reg [7:0] bank0[0:MemNum-1];
    reg [7:0] bank1[0:MemNum-1];
    reg [7:0] bank2[0:MemNum-1];
    reg [7:0] bank3[0:MemNum-1];

    wire [MemLog-1:0] saddr = addr[MemLog+1:2];

    always @(posedge clk) begin
        if (ce && we) begin
            if (sel[3]) bank3[saddr] <= data_i[31:24];
            if (sel[2]) bank2[saddr] <= data_i[23:16];
            if (sel[1]) bank1[saddr] <= data_i[15:8 ];
            if (sel[0]) bank0[saddr] <= data_i[7 :0 ];
        end
    end

    always @ (*) begin
        if (!ce)      data_o <= 0;
        else if (!we) data_o <= {bank3[saddr],bank2[saddr],bank1[saddr],bank0[saddr]};
        else          data_o <= 0;
    end

endmodule    