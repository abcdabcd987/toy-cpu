`include "consts.v"

module stage_ex (
    input      [ 7:0] aluop            ,
    input      [ 2:0] alusel           ,
    input      [31:0] opv1             ,
    input      [31:0] opv2             ,
    input             we               ,
    input      [ 4:0] waddr            ,
    output reg        we_o             ,
    output     [ 4:0] waddr_o          ,
    output reg [31:0] wdata            ,
    input      [31:0] hilo_hi          ,
    input      [31:0] hilo_lo          ,
    input             mem_we_hilo      ,
    input      [31:0] mem_hi           ,
    input      [31:0] mem_lo           ,
    input             wb_we_hilo       ,
    input      [31:0] wb_hi            ,
    input      [31:0] wb_lo            ,
    output reg        we_hilo          ,
    output reg [31:0] hi_o             ,
    output reg [31:0] lo_o             ,
    output reg        stallreq         ,
    input             cur_in_delay_slot,
    input      [31:0] link_addr        ,
    input      [31:0] inst             ,
    output     [ 7:0] aluop_o          ,
    output     [31:0] mem_addr         ,
    output     [31:0] opv2_o           ,
    input             rst
);

    reg [31:0] logic_out;
    reg [31:0] shift_out;
    reg [31:0] moves_out;
    reg [31:0] arith_out;
    reg [63:0] mul_out ;
    reg [31:0] hi       ;
    reg [31:0] lo       ;

    assign waddr_o  = waddr;
    assign aluop_o  = aluop;
    assign opv2_o   = opv2;
    assign mem_addr = opv1 + {{16{inst[15]}}, inst[15:0]};

    assign stallreq = 0;

    reg [31:0] clz_res;
    reg [31:0] clo_res;
    clz32 clz32(clz_res, opv1);
    clz32 clo32(clo_res, ~opv1);

    always @* begin
        mul_out <= 0;
        if (!rst) begin
            case (aluop)
                `EXE_MUL_OP   : mul_out <= $signed(opv1) * $signed(opv2);
                `EXE_MULT_OP  : mul_out <= $signed(opv1) * $signed(opv2);
                `EXE_MULTU_OP : mul_out <= opv1 * opv2;
            endcase
        end
    end

    always @* begin
        arith_out <= 0;
        if (!rst) begin
            case (aluop)
                `EXE_SLT_OP   : arith_out <= $signed(opv1) < $signed(opv2);
                `EXE_SLTU_OP  : arith_out <= opv1 < opv2;
                `EXE_ADD_OP   : arith_out <= $signed(opv1) + $signed(opv2);
                `EXE_ADDU_OP  : arith_out <= opv1 + opv2;
                `EXE_ADDI_OP  : arith_out <= $signed(opv1) + $signed(opv2);
                `EXE_ADDIU_OP : arith_out <= opv1 + opv2;
                `EXE_SUB_OP   : arith_out <= $signed(opv1) - $signed(opv2);
                `EXE_SUBU_OP  : arith_out <= opv1 - opv2;
                `EXE_CLZ_OP   : arith_out <= clz_res;
                `EXE_CLO_OP   : arith_out <= clo_res;
            endcase
        end
    end
    wire sum_overflow = ($signed(opv1) > 0 && $signed(opv2) > 0 && $signed(arith_out) < 0) 
                     || ($signed(opv1) < 0 && $signed(opv2) < 0 && $signed(arith_out) > 0);

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

    always @* begin
        case (aluop)
            `EXE_MFHI_OP : moves_out <= hi  ;
            `EXE_MFLO_OP : moves_out <= lo  ;
            `EXE_MOVZ_OP : moves_out <= opv1;
            `EXE_MOVN_OP : moves_out <= opv1;
            default      : moves_out <= 0   ;
        endcase
    end

    `define SET_HILO_OUT(i_we_hilo, i_hi_o, i_lo_o) do begin \
        we_hilo <= i_we_hilo  ; \
        hi_o    <= i_hi_o     ; \
        lo_o    <= i_lo_o     ; \
    end while (0)
    always @* begin
        case (aluop)
            `EXE_MULT_OP  : `SET_HILO_OUT(1, mul_out[63:32], mul_out[31:0]);
            `EXE_MULTU_OP : `SET_HILO_OUT(1, mul_out[63:32], mul_out[31:0]);
            `EXE_MTHI_OP  : `SET_HILO_OUT(1, opv1, lo);
            `EXE_MTLO_OP  : `SET_HILO_OUT(1, hi, opv1);
            `EXE_DIV_OP   : `SET_HILO_OUT(1, $signed(opv1) % $signed(opv2), $signed(opv1) / $signed(opv2));
            `EXE_DIVU_OP  : `SET_HILO_OUT(1, opv1 % opv2, opv1 / opv2);
            default       : `SET_HILO_OUT(0, 0, 0);
        endcase
    end
    `undef SET_HILO_OUT

    always @* begin
        we_o <= (aluop == `EXE_ADD_OP || aluop == `EXE_ADDI_OP || aluop == `EXE_SUB_OP)
            && sum_overflow == 1 ? 0 : we;
        case (alusel)
            `EXE_RES_LOGIC       : wdata <= logic_out;
            `EXE_RES_SHIFT       : wdata <= shift_out;
            `EXE_RES_MOVE        : wdata <= moves_out;
            `EXE_RES_ARITH       : wdata <= arith_out;
            `EXE_RES_MUL         : wdata <= mul_out[31:0];
            `EXE_RES_JUMP_BRANCH : wdata <= link_addr;
            default              : wdata <= 0;
        endcase
    end

endmodule // stage_ex

module clz32 (
    output reg [31:0] result,
    input      [31:0] value
);
    reg [15:0] val16;
    reg [7:0] val8;
    reg [3:0] val4;
    always @* begin
        result[31:6] = 0;
        if (value == 32'b0) begin
            result[5:0] = 32;
        end else begin
            result[5] = 0;
            result[4] = value[31:16] == 16'b0;
            val16     = result[4] ? value[15:0] : value[31:16];
            result[3] = val16[15:8] == 8'b0;
            val8      = result[3] ? val16[7:0] : val16[15:8];
            result[2] = val8[7:4] == 4'b0;
            val4      = result[2] ? val8[3:0] : val8[7:4];
            result[1] = val4[3:2] == 2'b0;
            result[0] = result[1] ? ~val4[1] : ~val4[3];
        end
    end
endmodule // clz32
