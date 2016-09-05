`include "consts.v"

module stage_id (
    input      [31:0] pc                 ,
    input      [31:0] inst               ,
    output reg        re1                ,
    input      [31:0] reg_data1          ,
    output reg [ 4:0] reg_addr1          ,
    output reg        re2                ,
    input      [31:0] reg_data2          ,
    output reg [ 4:0] reg_addr2          ,
    output reg [ 7:0] aluop              ,
    output reg [ 2:0] alusel             ,
    output reg [31:0] opv1               ,
    output reg [31:0] opv2               ,
    output reg        we                 ,
    output reg [ 4:0] waddr              ,
    input             ex_we              ,
    input      [ 4:0] ex_waddr           ,
    input      [31:0] ex_wdata           ,
    input             mem_we             ,
    input      [ 4:0] mem_waddr          ,
    input      [31:0] mem_wdata          ,
    output reg        stallreq           ,
    input      [ 7:0] ex_aluop           ,
    output reg        br                 ,
    output reg [31:0] br_addr            ,
    output reg        cur_in_delay_slot_o,
    output reg [31:0] link_addr          ,
    output reg        next_in_delay_slot ,
    input             cur_in_delay_slot_i,
    output reg [31:0] inst_o             ,
    input             rst
);

    assign inst_o = inst;

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
    wire [31:0] sext_imm = {{16{inst[15]}}, inst[15:0]};
    wire [31:0] pc4      = pc+4;
    wire [31:0] pc8      = pc+8;
    wire [31:0] pc_j     = {pc4[31:28], inst[25:0], 2'b00};
    wire [31:0] pc_b     = pc + 4 + {{14{inst[15]}}, inst[15:0], 2'b00};

    reg stallreq_for_reg1_loadrelate;
    reg stallreq_for_reg2_loadrelate;
    assign stallreq = stallreq_for_reg1_loadrelate || stallreq_for_reg2_loadrelate;
    assign prev_is_load = ex_aluop == `EXE_LB_OP  || 
                          ex_aluop == `EXE_LBU_OP ||
                          ex_aluop == `EXE_LH_OP  ||
                          ex_aluop == `EXE_LHU_OP ||
                          ex_aluop == `EXE_LW_OP  ||
                          ex_aluop == `EXE_LWR_OP ||
                          ex_aluop == `EXE_LWL_OP ||
                          ex_aluop == `EXE_LL_OP  ||
                          ex_aluop == `EXE_SC_OP;

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

    `define SET_BRANCH(i_br, i_br_addr, i_link_addr, i_next_in_delay_slot) do begin \
        br                  <= i_br                 ; \
        br_addr             <= i_br_addr            ; \
        link_addr           <= i_link_addr          ; \
        next_in_delay_slot  <= i_next_in_delay_slot ; \
    end while (0)

    assign cur_in_delay_slot_o = rst ? 0 : cur_in_delay_slot_i;

    always @* begin
        if (rst) begin
            `SET_INST(`EXE_NOP_OP, `EXE_RES_NOP, 0, rs, 0, rt, 0, rd, 0, 1);
            `SET_BRANCH(0, 0, 0, 0);
        end else begin
            `SET_INST(0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
            `SET_BRANCH(0, 0, 0, 0);
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
                    `EXE_SLT  : `SET_INST(`EXE_SLT_OP , `EXE_RES_ARITH, 1, rs, 1, rt, 1, rd, 0, 1);
                    `EXE_SLTU : `SET_INST(`EXE_SLTU_OP, `EXE_RES_ARITH, 1, rs, 1, rt, 1, rd, 0, 1);
                    `EXE_ADD  : `SET_INST(`EXE_ADD_OP , `EXE_RES_ARITH, 1, rs, 1, rt, 1, rd, 0, 1);
                    `EXE_ADDU : `SET_INST(`EXE_ADDU_OP, `EXE_RES_ARITH, 1, rs, 1, rt, 1, rd, 0, 1);
                    `EXE_SUB  : `SET_INST(`EXE_SUB_OP , `EXE_RES_ARITH, 1, rs, 1, rt, 1, rd, 0, 1);
                    `EXE_SUBU : `SET_INST(`EXE_SUBU_OP, `EXE_RES_ARITH, 1, rs, 1, rt, 1, rd, 0, 1);
                    `EXE_MULT : `SET_INST(`EXE_MULT_OP, `EXE_RES_ARITH, 1, rs, 1, rt, 1, rd, 0, 1);
                    `EXE_MULTU:`SET_INST(`EXE_MULTU_OP, `EXE_RES_ARITH, 1, rs, 1, rt, 1, rd, 0, 1);
                    `EXE_DIV  : `SET_INST(`EXE_DIV_OP , `EXE_RES_ARITH, 1, rs, 1, rt, 0, rd, 0, 1);
                    `EXE_DIVU : `SET_INST(`EXE_DIVU_OP, `EXE_RES_ARITH, 1, rs, 1, rt, 0, rd, 0, 1);
                    `EXE_JR   : begin
                        `SET_INST(`EXE_JR_OP  , `EXE_RES_JUMP_BRANCH, 1, rs, 0, rt, 0, rd, 0, 1);
                        `SET_BRANCH(1, opv1, 0, 1);
                    end
                    `EXE_JALR: begin
                        `SET_INST(`EXE_JALR_OP, `EXE_RES_JUMP_BRANCH, 1, rs, 0, rt, 1, rd, 0, 1);
                        `SET_BRANCH(1, opv1, pc8, 1);
                    end
                endcase
                `EXE_SPECIAL2_INST: case (opx)
                    `EXE_CLZ  : `SET_INST(`EXE_CLZ_OP , `EXE_RES_ARITH, 1, rs, 0, rt, 1, rd, 0, 1);
                    `EXE_CLO  : `SET_INST(`EXE_CLO_OP , `EXE_RES_ARITH, 1, rs, 0, rt, 1, rd, 0, 1);
                    `EXE_MUL  : `SET_INST(`EXE_MUL_OP , `EXE_RES_MUL  , 1, rs, 1, rt, 1, rd, 0, 1);
                endcase
                `EXE_ORI  : `SET_INST(`EXE_OR_OP  , `EXE_RES_LOGIC, 1, rs, 0, 0 , 1, rt, ({16'h0, inst_imm}), 1);
                `EXE_ANDI : `SET_INST(`EXE_AND_OP , `EXE_RES_LOGIC, 1, rs, 0, 0 , 1, rt, ({16'h0, inst_imm}), 1);
                `EXE_XORI : `SET_INST(`EXE_XOR_OP , `EXE_RES_LOGIC, 1, rs, 0, 0 , 1, rt, ({16'h0, inst_imm}), 1);
                `EXE_LUI  : `SET_INST(`EXE_OR_OP  , `EXE_RES_LOGIC, 1, rs, 0, 0 , 1, rt, ({inst_imm, 16'h0}), 1);
                `EXE_PREF : `SET_INST(`EXE_NOP_OP , `EXE_RES_NOP  , 0, rs, 0, 0 , 0, rt, 0                  , 1);
                `EXE_SLTI : `SET_INST(`EXE_SLT_OP , `EXE_RES_ARITH, 1, rs, 0, 0 , 1, rt, sext_imm           , 1);
                `EXE_SLTIU: `SET_INST(`EXE_SLTU_OP, `EXE_RES_ARITH, 1, rs, 0, 0 , 1, rt, sext_imm           , 1);
                `EXE_ADDI : `SET_INST(`EXE_ADDI_OP, `EXE_RES_ARITH, 1, rs, 0, 0 , 1, rt, sext_imm           , 1);
                `EXE_ADDIU: `SET_INST(`EXE_ADDIU_OP,`EXE_RES_ARITH, 1, rs, 0, 0 , 1, rt, sext_imm           , 1);
                `EXE_LB   : `SET_INST(`EXE_LB_OP , `EXE_RES_LOAD_STORE, 1, rs, 0, 0 , 1, rt, 0, 1);
                `EXE_LBU  : `SET_INST(`EXE_LBU_OP, `EXE_RES_LOAD_STORE, 1, rs, 0, 0 , 1, rt, 0, 1);
                `EXE_LH   : `SET_INST(`EXE_LH_OP , `EXE_RES_LOAD_STORE, 1, rs, 0, 0 , 1, rt, 0, 1);
                `EXE_LHU  : `SET_INST(`EXE_LHU_OP, `EXE_RES_LOAD_STORE, 1, rs, 0, 0 , 1, rt, 0, 1);
                `EXE_LW   : `SET_INST(`EXE_LW_OP , `EXE_RES_LOAD_STORE, 1, rs, 0, 0 , 1, rt, 0, 1);
                `EXE_LWL  : `SET_INST(`EXE_LWL_OP, `EXE_RES_LOAD_STORE, 1, rs, 1, rt, 1, rt, 0, 1);
                `EXE_LWR  : `SET_INST(`EXE_LWR_OP, `EXE_RES_LOAD_STORE, 1, rs, 1, rt, 1, rt, 0, 1);
                `EXE_SB   : `SET_INST(`EXE_SB_OP , `EXE_RES_LOAD_STORE, 1, rs, 1, rt, 0,  0, 0, 1);
                `EXE_SH   : `SET_INST(`EXE_SH_OP , `EXE_RES_LOAD_STORE, 1, rs, 1, rt, 0,  0, 0, 1);
                `EXE_SW   : `SET_INST(`EXE_SW_OP , `EXE_RES_LOAD_STORE, 1, rs, 1, rt, 0,  0, 0, 1);
                `EXE_SWL  : `SET_INST(`EXE_SWL_OP, `EXE_RES_LOAD_STORE, 1, rs, 1, rt, 0,  0, 0, 1);
                `EXE_SWR  : `SET_INST(`EXE_SWR_OP, `EXE_RES_LOAD_STORE, 1, rs, 1, rt, 0,  0, 0, 1);
                `EXE_LL   : `SET_INST(`EXE_LL_OP , `EXE_RES_LOAD_STORE, 1, rs, 0,  0, 1, rt, 0, 1);
                `EXE_SC   : `SET_INST(`EXE_SC_OP , `EXE_RES_LOAD_STORE, 1, rs, 1, rt, 1, rt, 0, 1);
                `EXE_J: begin
                    `SET_INST(`EXE_J_OP   , `EXE_RES_JUMP_BRANCH, 0, rs, 0, rt, 0, rd, 0, 1);
                    `SET_BRANCH(1, pc_j, 0, 1);
                end
                `EXE_JAL: begin
                    `SET_INST(`EXE_JAL_OP , `EXE_RES_JUMP_BRANCH, 0, rs, 0, rt, 1, 31, 0, 1);
                    `SET_BRANCH(1, pc_j, pc8, 1);
                end
                `EXE_BEQ: begin
                    `SET_INST(`EXE_BEQ_OP , `EXE_RES_JUMP_BRANCH, 1, rs, 1, rt, 0, rd, 0, 1);
                    if (opv1 == opv2) `SET_BRANCH(1, pc_b, 0, 1);
                end
                `EXE_BNE: begin
                    `SET_INST(`EXE_BNE_OP , `EXE_RES_JUMP_BRANCH, 1, rs, 1, rt, 0, rd, 0, 1);
                    if (opv1 != opv2) `SET_BRANCH(1, pc_b, 0, 1);
                end
                `EXE_BGTZ: begin
                    `SET_INST(`EXE_BGTZ_OP, `EXE_RES_JUMP_BRANCH, 1, rs, 0, rt, 0, rd, 0, 1);
                    if ($signed(opv1) > 0) `SET_BRANCH(1, pc_b, 0, 1);
                end
                `EXE_BLEZ: begin
                    `SET_INST(`EXE_BLEZ_OP, `EXE_RES_JUMP_BRANCH, 1, rs, 0, rt, 0, rd, 0, 1);
                    if ($signed(opv1) <= 0) `SET_BRANCH(1, pc_b, 0, 1);
                end
                `EXE_REGIMM_INST: case (rt)
                    `EXE_BGEZ: begin
                        `SET_INST(`EXE_BGEZ_OP  , `EXE_RES_JUMP_BRANCH, 1, rs, 0, rt, 0, rd, 0, 1);
                        if ($signed(opv1) >= 0) `SET_BRANCH(1, pc_b, 0, 1);
                    end
                    `EXE_BGEZAL: begin
                        if ($signed(opv1) >= 0) begin
                            `SET_INST(`EXE_BGEZAL_OP, `EXE_RES_JUMP_BRANCH, 1, rs, 0, rt, 1, 31, 0, 1);
                            `SET_BRANCH(1, pc_b, pc8, 1);
                        end else begin
                            `SET_INST(`EXE_BGEZAL_OP, `EXE_RES_JUMP_BRANCH, 1, rs, 0, rt, 0, 31, 0, 1);
                        end
                    end
                    `EXE_BLTZ: begin
                        `SET_INST(`EXE_BLTZ_OP  , `EXE_RES_JUMP_BRANCH, 1, rs, 0, rt, 0, rd, 0, 1);
                        if ($signed(opv1) < 0) `SET_BRANCH(1, pc_b, 0, 1);
                    end
                    `EXE_BLTZAL: begin
                        if ($signed(opv1) < 0) begin
                            `SET_INST(`EXE_BLTZAL_OP, `EXE_RES_JUMP_BRANCH, 1, rs, 0, rt, 1, 31, 0, 1);
                            `SET_BRANCH(1, pc_b, pc8, 1);
                        end else begin
                            `SET_INST(`EXE_BLTZAL_OP, `EXE_RES_JUMP_BRANCH, 1, rs, 0, rt, 0, 31, 0, 1);
                        end
                    end
                endcase
            endcase
        end
    end


    `define SET_OPV(opv, re, reg_addr, reg_data, stallreq) do begin \
        stallreq <= 0; \
        if (rst) opv <= 0; \
        else if (prev_is_load && ex_waddr == reg_addr && re) stallreq <= 1; \
        else if (!re) opv <= imm; \
        else if (ex_we && ex_waddr == reg_addr) opv <= ex_wdata; \
        else if (mem_we && mem_waddr == reg_addr) opv <= mem_wdata; \
        else opv <= reg_data; \
    end while (0)

    always @* `SET_OPV(opv1, re1, reg_addr1, reg_data1, stallreq_for_reg1_loadrelate);
    always @* `SET_OPV(opv2, re2, reg_addr2, reg_data2, stallreq_for_reg2_loadrelate);

    `undef SET_OPV
    `undef SET_INST
    `undef SET_BRANCH

endmodule // stage_id