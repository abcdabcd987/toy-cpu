`ifndef ASSERT_V
`define ASSERT_V

`define ASSERT(x) do begin \
        if (!(x)) begin \
            $display("\033[91;1m[%s:%0d]ASSERTION FAILURE: %s\033[0m", `__FILE__, `__LINE__, `"x`"); \
            $finish_and_return(1); \
        end \
    end while (0)

`define PASS #2 do begin $display("\033[92;1mTEST PASS\033[0m"); $finish; end while (0)

`define AR(id, expected) `ASSERT(top.openmips.regfile.regs[id] === expected)
`define AHI(expected) `ASSERT(top.openmips.reg_hilo.hi_o === expected)
`define ALO(expected) `ASSERT(top.openmips.reg_hilo.lo_o === expected)

`endif
