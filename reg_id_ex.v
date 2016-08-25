module reg_id_ex (
    input      [ 7:0] id_aluop ,
    input      [ 2:0] id_alusel,
    input      [31:0] id_opv1  ,
    input      [31:0] id_opv2  ,
    input             id_we    ,
    input      [ 5:0] id_waddr ,
    output reg [ 7:0] ex_aluop ,
    output reg [ 2:0] ex_alusel,
    output reg [31:0] ex_opv1  ,
    output reg [31:0] ex_opv2  ,
    output reg        ex_we    ,
    output reg [ 5:0] ex_waddr ,
    input             clk      ,
    input             rst
);

    always @(posedge clk) begin
        if (rst) begin
            ex_aluop <= 0; ex_alusel <= 0; // nop
            ex_opv1  <= 0; ex_opv2   <= 0;
            ex_we    <= 0; ex_waddr  <= 0;
        end else begin
            ex_aluop  <= id_aluop ;
            ex_alusel <= id_alusel;
            ex_opv1   <= id_opv1  ;
            ex_opv2   <= id_opv2  ;
            ex_we     <= id_we    ;
            ex_waddr  <= id_waddr ;
        end
    end

endmodule // reg_id_ex
