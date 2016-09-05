module stage_mem (
    input             we        ,
    input      [ 4:0] waddr     ,
    input      [31:0] wdata     ,
    output reg        we_o      ,
    output reg [ 4:0] waddr_o   ,
    output reg [31:0] wdata_o   ,
    input             we_hilo   ,
    input      [31:0] hi        ,
    input      [31:0] lo        ,
    output reg        we_hilo_o ,
    output reg [31:0] hi_o      ,
    output reg [31:0] lo_o      ,
    input      [ 7:0] aluop     ,
    input      [31:0] mem_addr  ,
    input      [31:0] opv2      ,
    input      [31:0] mem_data  ,
    output reg [31:0] mem_addr_o,
    output reg [ 3:0] mem_sel   ,
    output reg        mem_we    ,
    output reg [31:0] mem_data_o,
    output reg        mem_ce    ,
    input             rst
);

    `define SET_MEM(i_wdata_o, i_mem_addr_o, i_mem_sel, i_mem_we, i_mem_data_o, i_mem_ce) do begin \
        wdata_o    <= i_wdata_o   ; \
        mem_addr_o <= i_mem_addr_o; \
        mem_sel    <= i_mem_sel   ; \
        mem_we     <= i_mem_we    ; \
        mem_data_o <= i_mem_data_o; \
        mem_ce     <= i_mem_ce    ; \
    end while (0)

    always @* begin
        if (rst) begin
            we_o       <= 0;
            wdata_o    <= 0;
            we_hilo_o  <= 0;
            hi_o       <= 0;
            lo_o       <= 0;
            `SET_MEM(0, 0, 0, 0, 0, 0);
        end else begin
            we_o      <= we;
            waddr_o   <= waddr;
            wdata_o   <= wdata;
            we_hilo_o <= we_hilo;
            hi_o      <= hi;
            lo_o      <= lo;
            `SET_MEM(wdata, 0, 0, 0, 0, 0);
            case (aluop)
                `EXE_LB_OP : case (mem_addr[1:0])
                    2'b00  : `SET_MEM(({{24{mem_data[31]}},mem_data[31:24]}), mem_addr, 4'b1000, 0, 0, 1);
                    2'b01  : `SET_MEM(({{24{mem_data[23]}},mem_data[23:16]}), mem_addr, 4'b0100, 0, 0, 1);
                    2'b10  : `SET_MEM(({{24{mem_data[15]}},mem_data[15:8 ]}), mem_addr, 4'b0010, 0, 0, 1);
                    2'b11  : `SET_MEM(({{24{mem_data[7 ]}},mem_data[7 :0 ]}), mem_addr, 4'b0001, 0, 0, 1);
                endcase
                `EXE_LBU_OP: case (mem_addr[1:0])
                    2'b00  : `SET_MEM(({{24{1'b0}},mem_data[31:24]}), mem_addr, 4'b1000, 0, 0, 1);
                    2'b01  : `SET_MEM(({{24{1'b0}},mem_data[23:16]}), mem_addr, 4'b0100, 0, 0, 1);
                    2'b10  : `SET_MEM(({{24{1'b0}},mem_data[15:8 ]}), mem_addr, 4'b0010, 0, 0, 1);
                    2'b11  : `SET_MEM(({{24{1'b0}},mem_data[7 :0 ]}), mem_addr, 4'b0001, 0, 0, 1);
                endcase
                `EXE_LH_OP : case (mem_addr[1:0])
                    2'b00  : `SET_MEM(({{16{mem_data[31]}},mem_data[31:16]}), mem_addr, 4'b1100, 0, 0, 1);
                    2'b10  : `SET_MEM(({{16{mem_data[31]}},mem_data[15: 0]}), mem_addr, 4'b0011, 0, 0, 1);
                endcase
                `EXE_LHU_OP: case (mem_addr[1:0])
                    2'b00  : `SET_MEM(({{16{1'b0}},mem_data[31:16]}), mem_addr, 4'b1100, 0, 0, 1);
                    2'b10  : `SET_MEM(({{16{1'b0}},mem_data[15: 0]}), mem_addr, 4'b0011, 0, 0, 1);
                endcase
                `EXE_LW_OP : `SET_MEM(mem_data, mem_addr, 4'b1111, 0, 0, 1);
                `EXE_LWL_OP: case (mem_addr[1:0])
                    2'b00  : `SET_MEM((mem_data[31:0]             )  , ({mem_addr[31:2], 2'b00}), 4'b1111, 0, 0, 1);
                    2'b01  : `SET_MEM(({mem_data[23:0],opv2[7 :0]})  , ({mem_addr[31:2], 2'b00}), 4'b1111, 0, 0, 1);
                    2'b10  : `SET_MEM(({mem_data[15:0],opv2[15:0]})  , ({mem_addr[31:2], 2'b00}), 4'b1111, 0, 0, 1);
                    2'b11  : `SET_MEM(({mem_data[7 :0],opv2[23:0]})  , ({mem_addr[31:2], 2'b00}), 4'b1111, 0, 0, 1);
                endcase
                `EXE_LWR_OP: case (mem_addr[1:0])
                    2'b00  : `SET_MEM(({opv2[31:8 ],mem_data[31:24]}), ({mem_addr[31:2], 2'b00}), 4'b1111, 0, 0, 1);
                    2'b01  : `SET_MEM(({opv2[31:16],mem_data[31:16]}), ({mem_addr[31:2], 2'b00}), 4'b1111, 0, 0, 1);
                    2'b10  : `SET_MEM(({opv2[31:24],mem_data[31:8 ]}), ({mem_addr[31:2], 2'b00}), 4'b1111, 0, 0, 1);
                    2'b11  : `SET_MEM((mem_data                     ), ({mem_addr[31:2], 2'b00}), 4'b1111, 0, 0, 1);
                endcase
                `EXE_SB_OP: case (mem_addr[1:0])
                    2'b00  : `SET_MEM(0, mem_addr, 4'b1000, 1, ({opv2[7:0],opv2[7:0],opv2[7:0],opv2[7:0]}), 1);
                    2'b01  : `SET_MEM(0, mem_addr, 4'b0100, 1, ({opv2[7:0],opv2[7:0],opv2[7:0],opv2[7:0]}), 1);
                    2'b10  : `SET_MEM(0, mem_addr, 4'b0010, 1, ({opv2[7:0],opv2[7:0],opv2[7:0],opv2[7:0]}), 1);
                    2'b11  : `SET_MEM(0, mem_addr, 4'b0001, 1, ({opv2[7:0],opv2[7:0],opv2[7:0],opv2[7:0]}), 1);
                endcase
                `EXE_SH_OP: case (mem_addr[1:0])
                    2'b00  : `SET_MEM(0, mem_addr, 4'b1100, 1, ({opv2[15:0],opv2[15:0]}), 1);
                    2'b10  : `SET_MEM(0, mem_addr, 4'b0011, 1, ({opv2[15:0],opv2[15:0]}), 1);
                endcase
                `EXE_SW_OP: `SET_MEM(0, mem_addr, 4'b1111, 1, opv2, 1);
                `EXE_SWL_OP: case (mem_addr[1:0])
                    2'b00  : `SET_MEM(0, ({mem_addr[31:2], 2'b00}), 4'b1111, 1, (opv2               ), 1);
                    2'b01  : `SET_MEM(0, ({mem_addr[31:2], 2'b00}), 4'b0111, 1, ({8'b0 ,opv2[31: 8]}), 1);
                    2'b10  : `SET_MEM(0, ({mem_addr[31:2], 2'b00}), 4'b0011, 1, ({16'b0,opv2[31:16]}), 1);
                    2'b11  : `SET_MEM(0, ({mem_addr[31:2], 2'b00}), 4'b0001, 1, ({24'b0,opv2[31:24]}), 1);
                endcase
                `EXE_SWR_OP: case (mem_addr[1:0])
                    2'b00  : `SET_MEM(0, ({mem_addr[31:2], 2'b00}), 4'b1000, 1, ({opv2[7 :0],24'b0}), 1);
                    2'b01  : `SET_MEM(0, ({mem_addr[31:2], 2'b00}), 4'b1100, 1, ({opv2[15:0],16'b0}), 1);
                    2'b10  : `SET_MEM(0, ({mem_addr[31:2], 2'b00}), 4'b1110, 1, ({opv2[23:0], 8'b0}), 1);
                    2'b11  : `SET_MEM(0, ({mem_addr[31:2], 2'b00}), 4'b1111, 1, (opv2              ), 1);
                endcase
            endcase
        end
    end

    `undef SET_MEM

endmodule // stage_mem
