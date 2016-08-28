`include "consts.v"

module stage_ex (
    input      [ 7:0] aluop      ,
    input      [ 2:0] alusel     ,
    input      [31:0] opv1       ,
    input      [31:0] opv2       ,
    input             we         ,
    input      [ 4:0] waddr      ,
    output            we_o       ,
    output     [ 4:0] waddr_o    ,
    output reg [31:0] wdata      ,
    input      [31:0] hilo_hi    ,
    input      [31:0] hilo_lo    ,
    input             mem_we_hilo,
    input      [31:0] mem_hi     ,
    input      [31:0] mem_lo     ,
    input             wb_we_hilo ,
    input      [31:0] wb_hi      ,
    input      [31:0] wb_lo      ,
    output reg        we_hilo    ,
    output reg [31:0] hi_o       ,
    output reg [31:0] lo_o       ,
    input             rst
);

    reg [31:0] logic_out;
    reg [31:0] shift_out;
    reg [31:0] moves_out;
    reg [31:0] hi       ;
    reg [31:0] lo       ;

    assign we_o    = we;
    assign waddr_o = waddr;

    always @* begin
        if (rst) begin
            logic_out <= 0;
        end else begin
            case (aluop)
                `EXE_OR_OP  : logic_out <= opv1 | opv2;
                `EXE_AND_OP : logic_out <= opv1 & opv2;
                `EXE_NOR_OP : logic_out <= ~(opv1 | opv2);
                `EXE_XOR_OP : logic_out <= opv1 ^ opv2;
                default     : logic_out <= 0;
            endcase
        end
    end

    always @* begin
        if (rst) begin
            shift_out <= 0;
        end else begin
            case (aluop)
                `EXE_SLL_OP : shift_out <= opv2 << opv1[4:0];
                `EXE_SRL_OP : shift_out <= opv2 >> opv1[4:0];
                `EXE_SRA_OP : shift_out <= $signed(opv2) >>> opv1[4:0];
                default     : shift_out <= 0;
            endcase
        end
    end

    always @* begin
        if (rst) {hi, lo} <= {32'b0, 32'b0};
        else if (mem_we_hilo) {hi, lo} <= {mem_hi, mem_lo};
        else if (wb_we_hilo) {hi, lo} <= {wb_hi, wb_lo};
        else {hi, lo} <= {hilo_hi, hilo_lo};
    end

    `define SET_MOVE_OUTPUT(i_moves_out, i_we_hilo, i_hi_o, i_lo_o) do begin \
        moves_out <= i_moves_out; \
        we_hilo   <= i_we_hilo  ; \
        hi_o      <= i_hi_o     ; \
        lo_o      <= i_lo_o     ; \
    end while (0)

    always @* begin
        if (rst) begin
            `SET_MOVE_OUTPUT(0, 0, 0, 0);
        end else begin
            case (aluop)
                `EXE_MFHI_OP : `SET_MOVE_OUTPUT(hi  , 0, 0   , 0   );
                `EXE_MFLO_OP : `SET_MOVE_OUTPUT(lo  , 0, 0   , 0   );
                `EXE_MOVZ_OP : `SET_MOVE_OUTPUT(opv1, 0, 0   , 0   );
                `EXE_MOVN_OP : `SET_MOVE_OUTPUT(opv1, 0, 0   , 0   );
                `EXE_MTHI_OP : `SET_MOVE_OUTPUT(0   , 1, opv1, lo  );
                `EXE_MTLO_OP : `SET_MOVE_OUTPUT(0   , 1, hi  , opv1);
                default      : `SET_MOVE_OUTPUT(0   , 0, 0   , 0   );
            endcase
        end
    end

    `undef SET_MOVE_OUTPUT

    always @* begin
        case (alusel)
            `EXE_RES_LOGIC : wdata <= logic_out;
            `EXE_RES_SHIFT : wdata <= shift_out;
            `EXE_RES_MOVE  : wdata <= moves_out;
            default        : wdata <= 0;
        endcase
    end

endmodule // stage_ex
