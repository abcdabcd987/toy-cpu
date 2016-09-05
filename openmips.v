module openmips (
    input  [31:0] rom_data  ,
    output [31:0] rom_addr  ,
    output        rom_ce    ,
    input  [31:0] ram_data  ,
    output [31:0] ram_addr  ,
    output        ram_we    ,
    output [ 3:0] ram_sel   ,
    output [31:0] ram_data_o,
    output        ram_ce    ,
    input         clk       ,
    input         rst
);

    // stall
    wire [5:0] stall;
    wire stallreq_id;
    wire stallreq_ex;

    // PC -> IF/ID
    wire [31:0] pc_ifid_pc;

    // PC -> ROM
    assign rom_addr = pc_ifid_pc;

    // ID -> PC
    wire [31:0] id_pc_br_addr;
    wire        id_pc_br     ;

    // PC
    reg_pc reg_pc (
        .pc     (pc_ifid_pc   ),
        .ce     (rom_ce       ),
        .stall  (stall        ),
        .br     (id_pc_br     ),
        .br_addr(id_pc_br_addr),
        .clk    (clk          ),
        .rst    (rst          )
    );

    // IF/ID  ->  ID
    wire [31:0] ifid_id_pc, ifid_id_inst;

    // IF/ID
    reg_if_id reg_if_id (
        .if_pc  (pc_ifid_pc  ),
        .if_inst(rom_data    ),
        .id_pc  (ifid_id_pc  ),
        .id_inst(ifid_id_inst),
        .stall  (stall       ),
        .clk    (clk         ),
        .rst    (rst         )
    );

    // ID -> RegFile
    wire       id_reg_re1, id_reg_re2;
    wire [4:0] id_reg_addr1, id_reg_addr2;

    // RegFile -> ID
    wire [31:0] reg_id_data1, reg_id_data2;

    // ID -> ID/EX
    wire [ 7:0] id_idex_aluop             ;
    wire [ 2:0] id_idex_alusel            ;
    wire [31:0] id_idex_opv1              ;
    wire [31:0] id_idex_opv2              ;
    wire        id_idex_we                ;
    wire [ 4:0] id_idex_waddr             ;
    wire        id_idex_cur_in_delay_slot ;
    wire [31:0] id_idex_link_addr         ;
    wire        id_idex_next_in_delay_slot;
    wire [31:0] id_idex_inst              ;

    // ID/EX -> ID
    wire idex_id_cur_in_delay_slot;

    // EX -> ID
    wire        ex_id_we   ;
    wire [ 4:0] ex_id_waddr;
    wire [31:0] ex_id_wdata;
    wire [ 7:0] ex_id_aluop;

    // MEM -> ID
    wire        mem_id_we   ;
    wire [ 4:0] mem_id_waddr;
    wire [31:0] mem_id_wdata;

    // ID
    stage_id stage_id (
        .pc                 (ifid_id_pc                ),
        .inst               (ifid_id_inst              ),
        .re1                (id_reg_re1                ),
        .reg_data1          (reg_id_data1              ),
        .reg_addr1          (id_reg_addr1              ),
        .re2                (id_reg_re2                ),
        .reg_data2          (reg_id_data2              ),
        .reg_addr2          (id_reg_addr2              ),
        .aluop              (id_idex_aluop             ),
        .alusel             (id_idex_alusel            ),
        .opv1               (id_idex_opv1              ),
        .opv2               (id_idex_opv2              ),
        .we                 (id_idex_we                ),
        .waddr              (id_idex_waddr             ),
        .ex_we              (ex_id_we                  ),
        .ex_waddr           (ex_id_waddr               ),
        .ex_wdata           (ex_id_wdata               ),
        .mem_we             (mem_id_we                 ),
        .mem_waddr          (mem_id_waddr              ),
        .mem_wdata          (mem_id_wdata              ),
        .stallreq           (stallreq_id               ),
        .ex_aluop           (ex_id_aluop               ),
        .br                 (id_pc_br                  ),
        .br_addr            (id_pc_br_addr             ),
        .cur_in_delay_slot_o(id_idex_cur_in_delay_slot ),
        .link_addr          (id_idex_link_addr         ),
        .next_in_delay_slot (id_idex_next_in_delay_slot),
        .cur_in_delay_slot_i(idex_id_cur_in_delay_slot ),
        .inst_o             (id_idex_inst              ),
        .rst                (rst                       )
    );

    // ID/EX -> EX
    wire [ 7:0] idex_ex_aluop            ;
    wire [ 2:0] idex_ex_alusel           ;
    wire [31:0] idex_ex_opv1             ;
    wire [31:0] idex_ex_opv2             ;
    wire        idex_ex_we               ;
    wire [ 4:0] idex_ex_waddr            ;
    wire        idex_ex_cur_in_delay_slot;
    wire [31:0] idex_ex_link_addr        ;
    wire [31:0] idex_ex_inst             ;

    // ID/EX
    reg_id_ex reg_id_ex (
        .id_aluop             (id_idex_aluop             ),
        .id_alusel            (id_idex_alusel            ),
        .id_opv1              (id_idex_opv1              ),
        .id_opv2              (id_idex_opv2              ),
        .id_we                (id_idex_we                ),
        .id_waddr             (id_idex_waddr             ),
        .ex_aluop             (idex_ex_aluop             ),
        .ex_alusel            (idex_ex_alusel            ),
        .ex_opv1              (idex_ex_opv1              ),
        .ex_opv2              (idex_ex_opv2              ),
        .ex_we                (idex_ex_we                ),
        .ex_waddr             (idex_ex_waddr             ),
        .stall                (stall                     ),
        .id_cur_in_delay_slot (id_idex_cur_in_delay_slot ),
        .id_link_addr         (id_idex_link_addr         ),
        .id_next_in_delay_slot(id_idex_next_in_delay_slot),
        .ex_cur_in_delay_slot (idex_ex_cur_in_delay_slot ),
        .ex_link_addr         (idex_ex_link_addr         ),
        .ex_next_in_delay_slot(idex_id_cur_in_delay_slot ),
        .id_inst              (id_idex_inst              ),
        .ex_inst              (idex_ex_inst              ),
        .clk                  (clk                       ),
        .rst                  (rst                       )
    );

    // EX -> EX/MEM
    wire        ex_exmem_we      ;
    wire [ 4:0] ex_exmem_waddr   ;
    wire [31:0] ex_exmem_wdata   ;
    wire        ex_exmem_we_hilo ;
    wire [31:0] ex_exmem_hi      ;
    wire [31:0] ex_exmem_lo      ;
    wire [ 7:0] ex_exmem_aluop   ;
    wire [31:0] ex_exmem_mem_addr;
    wire [31:0] ex_exmem_opv2    ;
    assign ex_id_we    = ex_exmem_we   ;
    assign ex_id_waddr = ex_exmem_waddr;
    assign ex_id_wdata = ex_exmem_wdata;
    assign ex_id_aluop = ex_exmem_aluop;

    // MEM -> EX
    wire        mem_ex_we_hilo;
    wire [31:0] mem_ex_hi     ;
    wire [31:0] mem_ex_lo     ;

    // WB -> EX
    wire        wb_ex_we_hilo;
    wire [31:0] wb_ex_hi     ;
    wire [31:0] wb_ex_lo     ;

    // HILO -> EX
    wire [31:0] hilo_ex_hi;
    wire [31:0] hilo_ex_lo;

    // EX
    stage_ex stage_ex (
        .aluop            (idex_ex_aluop            ),
        .alusel           (idex_ex_alusel           ),
        .opv1             (idex_ex_opv1             ),
        .opv2             (idex_ex_opv2             ),
        .we               (idex_ex_we               ),
        .waddr            (idex_ex_waddr            ),
        .we_o             (ex_exmem_we              ),
        .waddr_o          (ex_exmem_waddr           ),
        .wdata            (ex_exmem_wdata           ),
        .hilo_hi          (hilo_ex_hi               ),
        .hilo_lo          (hilo_ex_lo               ),
        .mem_we_hilo      (mem_ex_we_hilo           ),
        .mem_hi           (mem_ex_hi                ),
        .mem_lo           (mem_ex_lo                ),
        .wb_we_hilo       (wb_ex_we_hilo            ),
        .wb_hi            (wb_ex_hi                 ),
        .wb_lo            (wb_ex_lo                 ),
        .we_hilo          (ex_exmem_we_hilo         ),
        .hi_o             (ex_exmem_hi              ),
        .lo_o             (ex_exmem_lo              ),
        .stallreq         (stallreq_ex              ),
        .cur_in_delay_slot(idex_ex_cur_in_delay_slot),
        .link_addr        (idex_ex_link_addr        ),
        .inst             (idex_ex_inst             ),
        .aluop_o          (ex_exmem_aluop           ),
        .mem_addr         (ex_exmem_mem_addr        ),
        .opv2_o           (ex_exmem_opv2            ),
        .rst              (rst                      )
    );

    // EX/MEM -> MEM
    wire        exmem_mem_we     ;
    wire [ 4:0] exmem_mem_waddr  ;
    wire [31:0] exmem_mem_wdata  ;
    wire        exmem_mem_we_hilo;
    wire [31:0] exmem_mem_hi     ;
    wire [31:0] exmem_mem_lo     ;
    wire [ 7:0] exmem_mem_aluop   ;
    wire [31:0] exmem_mem_mem_addr;
    wire [31:0] exmem_mem_opv2    ;

    // EX/MEM
    reg_ex_mem reg_ex_mem (
        .ex_we       (ex_exmem_we       ),
        .ex_waddr    (ex_exmem_waddr    ),
        .ex_wdata    (ex_exmem_wdata    ),
        .mem_we      (exmem_mem_we      ),
        .mem_waddr   (exmem_mem_waddr   ),
        .mem_wdata   (exmem_mem_wdata   ),
        .ex_we_hilo  (ex_exmem_we_hilo  ),
        .ex_hi       (ex_exmem_hi       ),
        .ex_lo       (ex_exmem_lo       ),
        .mem_we_hilo (exmem_mem_we_hilo ),
        .mem_hi      (exmem_mem_hi      ),
        .mem_lo      (exmem_mem_lo      ),
        .stall       (stall             ),
        .ex_aluop    (ex_exmem_aluop    ),
        .ex_mem_addr (ex_exmem_mem_addr ),
        .ex_opv2     (ex_exmem_opv2     ),
        .mem_aluop   (exmem_mem_aluop   ),
        .mem_mem_addr(exmem_mem_mem_addr),
        .mem_opv2    (exmem_mem_opv2    ),
        .clk         (clk               ),
        .rst         (rst               )
    );

    // MEM -> MEM/WB
    wire        mem_memwb_we         ;
    wire [ 4:0] mem_memwb_waddr      ;
    wire [31:0] mem_memwb_wdata      ;
    wire        mem_memwb_we_hilo    ;
    wire [31:0] mem_memwb_hi         ;
    wire [31:0] mem_memwb_lo         ;
    wire        mem_memwb_LLbit_we   ;
    wire        mem_memwb_LLbit_value;
    assign mem_id_we      = mem_memwb_we   ;
    assign mem_id_waddr   = mem_memwb_waddr;
    assign mem_id_wdata   = mem_memwb_wdata;
    assign mem_ex_we_hilo = mem_memwb_we_hilo;
    assign mem_ex_hi      = mem_memwb_hi     ;
    assign mem_ex_lo      = mem_memwb_lo     ;

    // MEM/WB -> MEM
    wire memwb_mem_LLbit_we;
    wire memwb_mem_LLbit_value;

    // LLbit -> MEM
    wire LLbit_mem_LLbit;

    // MEM
    stage_mem stage_mem (
        .we              (exmem_mem_we         ),
        .waddr           (exmem_mem_waddr      ),
        .wdata           (exmem_mem_wdata      ),
        .we_o            (mem_memwb_we         ),
        .waddr_o         (mem_memwb_waddr      ),
        .wdata_o         (mem_memwb_wdata      ),
        .we_hilo         (exmem_mem_we_hilo    ),
        .hi              (exmem_mem_hi         ),
        .lo              (exmem_mem_lo         ),
        .we_hilo_o       (mem_memwb_we_hilo    ),
        .hi_o            (mem_memwb_hi         ),
        .lo_o            (mem_memwb_lo         ),
        .aluop           (exmem_mem_aluop      ),
        .mem_addr        (exmem_mem_mem_addr   ),
        .opv2            (exmem_mem_opv2       ),
        .mem_data        (ram_data             ),
        .mem_addr_o      (ram_addr             ),
        .mem_sel         (ram_sel              ),
        .mem_we          (ram_we               ),
        .mem_data_o      (ram_data_o           ),
        .mem_ce          (ram_ce               ),
        .LLbit_i         (LLbit_mem_LLbit      ),
        .wb_LLbit_we_i   (memwb_mem_LLbit_we   ),
        .wb_LLbit_value_i(memwb_mem_LLbit_value),
        .LLbit_we_o      (mem_memwb_LLbit_we   ),
        .LLbit_value_o   (mem_memwb_LLbit_value),
        .rst             (rst                  )
    );

    // MEM/WB -> RegFile
    wire        memwb_reg_we   ;
    wire [ 4:0] memwb_reg_waddr;
    wire [31:0] memwb_reg_wdata;

    // MEM/WB -> HILO
    wire        memwb_hilo_we_hilo;
    wire [31:0] memwb_hilo_hi     ;
    wire [31:0] memwb_hilo_lo     ;
    assign wb_ex_we_hilo = memwb_hilo_we_hilo;
    assign wb_ex_hi      = memwb_hilo_hi     ;
    assign wb_ex_lo      = memwb_hilo_lo     ;

    // MEM/WB -> LLbit
    wire memwb_LLbit_we;
    wire memwb_LLbit_value;

    // MEM/WB
    reg_mem_wb reg_mem_wb (
        .mem_we         (mem_memwb_we         ),
        .mem_waddr      (mem_memwb_waddr      ),
        .mem_wdata      (mem_memwb_wdata      ),
        .wb_we          (memwb_reg_we         ),
        .wb_waddr       (memwb_reg_waddr      ),
        .wb_wdata       (memwb_reg_wdata      ),
        .mem_we_hilo    (mem_memwb_we_hilo    ),
        .mem_hi         (mem_memwb_hi         ),
        .mem_lo         (mem_memwb_lo         ),
        .wb_we_hilo     (memwb_hilo_we_hilo   ),
        .wb_hi          (memwb_hilo_hi        ),
        .wb_lo          (memwb_hilo_lo        ),
        .stall          (stall                ),
        .mem_LLbit_we   (mem_memwb_LLbit_we   ),
        .mem_LLbit_value(mem_memwb_LLbit_value),
        .wb_LLbit_we    (memwb_LLbit_we       ),
        .wb_LLbit_value (memwb_LLbit_value    ),
        .clk            (clk                  ),
        .rst            (rst                  )
    );

    // RegFile
    regfile regfile (
        .we    (memwb_reg_we   ),
        .waddr (memwb_reg_waddr),
        .wdata (memwb_reg_wdata),
        .re1   (id_reg_re1     ),
        .raddr1(id_reg_addr1   ),
        .rdata1(reg_id_data1   ),
        .re2   (id_reg_re2     ),
        .raddr2(id_reg_addr2   ),
        .rdata2(reg_id_data2   ),
        .clk   (clk            ),
        .rst   (rst            )
    );

    // HILO
    reg_hilo reg_hilo (
        .hi_o(hilo_ex_hi        ),
        .lo_o(hilo_ex_lo        ),
        .we  (memwb_hilo_we_hilo),
        .hi_i(memwb_hilo_hi     ),
        .lo_i(memwb_hilo_lo     ),
        .clk (clk               ),
        .rst (rst               )
    );

    // stall ctrl
    ctrl ctrl (
        .stallreq_id(stallreq_id),
        .stallreq_ex(stallreq_ex),
        .stall      (stall),
        .rst        (rst)
    );

    // LLbit
    reg_LLbit reg_LLbit (
        .flush  (1'b0             ),
        .LLbit_i(memwb_LLbit_value),
        .we     (memwb_LLbit_we   ),
        .LLbit_o(LLbit_mem_LLbit  ),
        .clk    (clk              ),
        .rst    (rst              )
    );

endmodule // openmips