module ctrl (
    input  wire       stallreq_id,
    input  wire       stallreq_ex,
    output reg  [5:0] stall           ,
    input  wire       rst
);

    always @ (*) begin
        if(rst) stall <= 6'b000000;
        else if (stallreq_ex) stall <= 6'b001111;
        else if (stallreq_id) stall <= 6'b000111;
        else stall <= 6'b000000;
    end

endmodule    