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
    input             rst
);

    reg [31:0] imm       ;
    reg        inst_valid;
    wire [6:0] op;
    assign op = inst[31:26];

    always @* begin
        if (rst) begin
            alusel     <= 0; aluop <= 0; // nop
            we         <= 0; waddr <= 0;
            re1        <= 0; reg_addr1 <= 0;
            re2        <= 0; reg_addr2 <= 0;
            imm        <= 0;
            inst_valid <= 1;
        end else begin
            alusel     <= 0; aluop <= 0; // nop
            we         <= 0; waddr <= 0;
            re1        <= 0; re2   <= 0;
            imm        <= 0;
            inst_valid <= 0;
            reg_addr1  <= inst[25:21];
            reg_addr2  <= inst[20:16];

            case (op)
                6'b001101 : begin // ori
                    alusel     <= 3'b001;
                    aluop      <= 8'b00100101;
                    waddr      <= inst[20:16]; we <= 1;
                    re1        <= 1; re2 <= 0;
                    imm        <= {16'h0, inst[15:0]};
                    inst_valid <= 1;
                end
            endcase
        end
    end

    always @* begin
        if (rst) begin
            opv1 <= 0;
        end else begin
            opv1 <= re1 ? reg_data1 : imm;
        end
    end

    always @* begin
        if (rst) begin
            opv2 <= 0;
        end else begin
            opv2 <= re2 ? reg_data2 : imm;
        end
    end


endmodule // stage_id