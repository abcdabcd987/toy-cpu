module stage_ex (
    input      [ 7:0] aluop  ,
    input      [ 2:0] alusel ,
    input      [31:0] opv1   ,
    input      [31:0] opv2   ,
    input             we     ,
    input      [ 4:0] waddr  ,
    output            we_o   ,
    output     [ 4:0] waddr_o,
    output reg [31:0] wdata  ,
    input             rst
);

    reg [31:0] logic_out;

    assign we_o    = we;
    assign waddr_o = waddr;

    always @* begin
        if (rst) begin
            logic_out <= 0;
        end else begin
            case (aluop)
                8'b00100101 : logic_out <= opv1 | opv2;
                default     : logic_out <= 0;
            endcase
        end
    end

    always @* begin
        case (alusel)
            3'b001  : wdata <= logic_out;
            default : wdata <= 0;
        endcase
    end

endmodule // stage_ex
