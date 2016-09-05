module reg_LLbit (
  input  wire flush  ,
  input  wire LLbit_i,
  input  wire we     ,
  output reg  LLbit_o,
  input  wire clk    ,
  input  wire rst
);

    always @ (posedge clk) begin
        if (rst || flush) LLbit_o <= 0;
        else if (we) LLbit_o <= LLbit_i;
    end

endmodule
