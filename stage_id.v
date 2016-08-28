`include "consts.v"

module stage_id (
    input      [31:0] pc       ,
    input      [31:0] inst     ,
    output reg        re1      ,
    input      [31:0] reg_data1,
    output reg [ 4:0] reg_addr1,
    output reg        re2      ,
    input      [31:0] reg_data2,
    output reg [ 4:0] reg_addr2,
    output reg [ 7:0] aluop    ,
    output reg [ 2:0] alusel   ,
    output reg [31:0] opv1     ,
    output reg [31:0] opv2     ,
    output reg        we       ,
    output reg [ 4:0] waddr    ,
    input             ex_we    ,
    input      [ 4:0] ex_waddr ,
    input      [31:0] ex_wdata ,
    input             mem_we   ,
    input      [ 4:0] mem_waddr,
    input      [31:0] mem_wdata,
    input             rst
);

    reg [31:0] imm       ;
    reg        inst_valid;

    wire [5:0] op  = inst[31:26];
    wire [5:0] op2 = inst[25:21];
    wire [5:0] opx = inst[5:0]  ;

    wire [ 4:0] rs       = inst[25:21];
    wire [ 4:0] rt       = inst[20:16];
    wire [ 4:0] rd       = inst[15:11];
    wire [ 5:0] sa       = inst[10:6] ;
    wire [15:0] inst_imm = inst[15:0] ;

    `define SET_INST(i_aluop, i_alusel, i_re1, i_reg_addr1, i_re2, i_reg_addr2, i_we, i_waddr, i_imm, i_inst_valid) do begin \
        aluop      <= i_aluop     ; \
        alusel     <= i_alusel    ; \
        re1        <= i_re1       ; \
        reg_addr1  <= i_reg_addr1 ; \
        re2        <= i_re2       ; \
        reg_addr2  <= i_reg_addr2 ; \
        we         <= i_we        ; \
        waddr      <= i_waddr     ; \
        imm        <= i_imm       ; \
        inst_valid <= i_inst_valid; \
    end while (0)

    always @* begin
        if (rst) begin
            `SET_INST(`EXE_NOP_OP, `EXE_RES_NOP, 0, rs, 0, rt, 0, rd, 0, 1);
        end else begin
            `SET_INST(0, 0, 0, 0, 0, 0, 0, 0, 0, 0);    
            case (op)
                `EXE_SPECIAL_INST : case (opx)
                    `EXE_OR   : `SET_INST(`EXE_OR_OP  , `EXE_RES_LOGIC, 1, rs, 1, rt, 1, rd, 0 , 1);
                    `EXE_AND  : `SET_INST(`EXE_AND_OP , `EXE_RES_LOGIC, 1, rs, 1, rt, 1, rd, 0 , 1);
                    `EXE_XOR  : `SET_INST(`EXE_XOR_OP , `EXE_RES_LOGIC, 1, rs, 1, rt, 1, rd, 0 , 1);
                    `EXE_NOR  : `SET_INST(`EXE_NOR_OP , `EXE_RES_LOGIC, 1, rs, 1, rt, 1, rd, 0 , 1);
                    `EXE_SLLV : `SET_INST(`EXE_SLL_OP , `EXE_RES_SHIFT, 1, rs, 1, rt, 1, rd, 0 , 1);
                    `EXE_SRLV : `SET_INST(`EXE_SRL_OP , `EXE_RES_SHIFT, 1, rs, 1, rt, 1, rd, 0 , 1);
                    `EXE_SRAV : `SET_INST(`EXE_SRA_OP , `EXE_RES_SHIFT, 1, rs, 1, rt, 1, rd, 0 , 1);
                    `EXE_SLL  : `SET_INST(`EXE_SLL_OP , `EXE_RES_SHIFT, 0, rs, 1, rt, 1, rd, sa, 1);
                    `EXE_SRL  : `SET_INST(`EXE_SRL_OP , `EXE_RES_SHIFT, 0, rs, 1, rt, 1, rd, sa, 1);
                    `EXE_SRA  : `SET_INST(`EXE_SRA_OP , `EXE_RES_SHIFT, 0, rs, 1, rt, 1, rd, sa, 1);
                    `EXE_SYNC : `SET_INST(`EXE_NOP_OP , `EXE_RES_NOP  , 0, rs, 0, rt, 0, rd, 0 , 1);
                    `EXE_MFHI : `SET_INST(`EXE_MFHI_OP, `EXE_RES_MOVE , 0, rs, 0, rt, 1, rd, 0 , 1);
                    `EXE_MFLO : `SET_INST(`EXE_MFLO_OP, `EXE_RES_MOVE , 0, rs, 0, rt, 1, rd, 0 , 1);
                    `EXE_MTHI : `SET_INST(`EXE_MTHI_OP, `EXE_RES_MOVE , 1, rs, 0, rt, 0, rd, 0 , 1);
                    `EXE_MTLO : `SET_INST(`EXE_MTLO_OP, `EXE_RES_MOVE , 1, rs, 0, rt, 0, rd, 0 , 1);
                    `EXE_MOVN : `SET_INST(`EXE_MOVN_OP, `EXE_RES_MOVE , 1, rs, 1, rt, opv2 != 0, rd, 0, 1);
                    `EXE_MOVZ : `SET_INST(`EXE_MOVZ_OP, `EXE_RES_MOVE , 1, rs, 1, rt, opv2 == 0, rd, 0, 1);
                endcase
                `EXE_ORI  : `SET_INST(`EXE_OR_OP,  `EXE_RES_LOGIC, 1, rs, 0, 0 , 1, rt, ({16'h0, inst_imm}), 1);
                `EXE_ANDI : `SET_INST(`EXE_AND_OP, `EXE_RES_LOGIC, 1, rs, 0, 0 , 1, rt, ({16'h0, inst_imm}), 1);
                `EXE_XORI : `SET_INST(`EXE_XOR_OP, `EXE_RES_LOGIC, 1, rs, 0, 0 , 1, rt, ({16'h0, inst_imm}), 1);
                `EXE_LUI  : `SET_INST(`EXE_OR_OP , `EXE_RES_LOGIC, 1, rs, 0, 0 , 1, rt, ({inst_imm, 16'h0}), 1);
                `EXE_PREF : `SET_INST(`EXE_NOP_OP, `EXE_RES_NOP  , 0, rs, 0, rt, 0, rd, 0                  , 1);
            endcase
        end
    end


    `define SET_OPV(opv, re, reg_addr, reg_data) do begin \
        if (rst) opv <= 0; \
        else if (!re) opv <= imm; \
        else if (ex_we && ex_waddr == reg_addr) opv <= ex_wdata; \
        else if (mem_we && mem_waddr == reg_addr) opv <= mem_wdata; \
        else opv <= reg_data; \
    end while (0)

    always @* `SET_OPV(opv1, re1, reg_addr1, reg_data1);
    always @* `SET_OPV(opv2, re2, reg_addr2, reg_data2);

    `undef SET_OPV
    `undef SET_INST

endmodule // stage_id