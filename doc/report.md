# MIPS 五级流水仿真实验报告

### 陈乐群 2016年9月6日

## 作业简介

作业实现了一个简易的和 OpenMIPS 兼容的五级流水处理器，指令内存和数据内存分开，乘法器和除法器用的是内建的 `*` 和 `/`。项目从架构上没有什么特别的地方，大量参考[《自己动手写CPU》](http://blog.csdn.net/leishangwen/article/category/5723475)。主要原因还是因为这个作业拖到了现在才做，要是在上学期教学周就做的话，兴许会加上 Tomasulo 之类好玩的东西，但现在就不想折腾了。

运行测试程序的方法：

```bash
cd test
make
```

虽然这个作业做得没什么新意，不过在我还是有一些技术和工具上的小点可以和大家分享。

## 多次 `<=` 赋值

这里有一个很好的例子：<http://stackoverflow.com/a/15732382/1332817>

```verilog
always @(posedge clk) begin
  out_one <= 1'b0;
  out_two <= 1'b0;
  out_thr <= 1'b0;
  case (state)
    2'd1 : out_one <= 1'b1;
    2'd2 : out_two <= 1'b1;
    2'd3 : out_thr <= 1'b1;
  endcase
end
```

多次使用 `<=` 赋值会取最后一个定义的为准。我觉得可以简单理解成语法糖，因为这个糖确实很好吃呀，这么写很多事情都变得方便了。

## `$dumpvars`

一开始的时候用 `$dumpvars;` 导出了所有变量，可是在 `GTKWave` 里面并找不到数组变量。后来看到 <http://iverilog.wikia.com/wiki/Verilog_Portability_Notes> 说的才知道还要手动指定才行。

> Icarus has the ability to dump individual array words. They are only dumped when explicitly passed to $dumpvars.  They are not dumped by default. For example given the following:

```verilog
 module top;
   reg [7:0] array [2:0];
   initial begin
     $dumpvars(0, array[0], array[1]);
     ...
   end
 endmodule
```
 
另外，如果 ram 做成多个 bank 的话，看波形会不方便，因为每个 bank 只存储了一个字节。这个时候用先把他们单独连出来就好看了，比如：

```verilog
wire [31:0] mem0x0000 = {top.ram.bank3[0], top.ram.bank2[0], top.ram.bank1[0], top.ram.bank0[0]};
wire [31:0] mem0x0004 = {top.ram.bank3[1], top.ram.bank2[1], top.ram.bank1[1], top.ram.bank0[1]};
wire [31:0] mem0x0008 = {top.ram.bank3[2], top.ram.bank2[2], top.ram.bank1[2], top.ram.bank0[2]};
```


## 块选择和自动格式化

Sublime Text 本身支持块选择，加上 [SystemVerilog](https://packagecontrol.io/packages/SystemVerilog) 插件的自动格式化，写起程序来非常高效。不多说，随便举个例子，上个动图大家体会一下：

![editor](https://github.com/abcdabcd987/toy-cpu/blob/master/doc/editor.gif?raw=true)

## 宏定义

在[ID阶段](https://github.com/abcdabcd987/toy-cpu/blob/master/src/stage_id.v#L69)要根据不同指令做出设置，这些设置其实都很类似，如果拆开写的话非常占空间，出错了也不容易发现。这个时候用宏定义一个函数问题就解决了，不仅变得非常美观，而且因为排列整齐，非常容易看出错误。

```verilog
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
```

大家可以发现，这个宏的写法和 C 里面是完全一样的，甚至连 `do while(0)` 这个梗原样复制过来都没有问题。下面是一张效果图：

![macro](https://github.com/abcdabcd987/toy-cpu/blob/master/doc/macro.png?raw=true)

另外宏还可以去掉一部分重复代码，提高程序的可维护性。

## 自动化测试

之前写测试的时候都是先把波形图导出来，然后在 GTKWave 上面看波形、作比对。头一次测试的时候这么做没有什么问题。然而，随着我们修改程序，我们想要保证最起码之前能过的测试现在也能过。这个时候如果我们再回头把所有测试的波形图都检查一遍，那真的是太累了。所以说，自动化的测试很有必要。

本来我看 [System Verilog 是有 `assert` 功能的](https://www.doulos.com/knowhow/sysverilog/tutorial/assertions/)，但是不知道为什么 `iverilog` 就是不支持。算了，没有那我们就[自己造](https://github.com/abcdabcd987/toy-cpu/blob/master/test/assert.v)，反正我已经发现了 Verilog 的宏和 C 的宏还是很像的：

```verilog
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
```

有了这个小轮子后，根据期望的波形图就很容易写出来测试程序，比如：

![gtkwave](https://github.com/abcdabcd987/toy-cpu/blob/master/doc/gtkwave.png?raw=true)

![testbench](https://github.com/abcdabcd987/toy-cpu/blob/master/doc/testbench.png?raw=true)

跑起来之后，如果能通过，会显示 `TEST PASS`，如果不能通过，就会报错并停下来，非常省心。

![assert_failure](https://github.com/abcdabcd987/toy-cpu/blob/master/doc/assert_failure.png?raw=true)

## Makefile

既然有了这么方便的自动化测试，那为何不顺手写个 [Makefile](https://github.com/abcdabcd987/toy-cpu/blob/master/test/Makefile) 呢。运行 `make` 就能跑所有测试点，运行 `make inst_jump_test` 就能测试跳转指令……

```makefile
.PHONY: all test
all: prepare \
	ori_forwarding_test \
	inst_shift_test \
	inst_logic_test \
	inst_move_test \
	inst_simple_arith_test \
	inst_jump_test \
	inst_br_test \
	inst_load_store_test \
	inst_load_stall_test \
	inst_ll_sc_test \

prepare:
	mkdir -p out

clean:
	rm -rf out/ *.vcd ../data/*.txt

%_test:
	@printf "\e[96;1m===================== %s\e[0m\n" $@
	(cd ../data && ./compile.py $@.s $@.txt)
	iverilog -o out/$@ -g2009 -I../src ../src/*.v $@.v
	out/$@

```

![make](https://github.com/abcdabcd987/toy-cpu/blob/master/doc/make.gif?raw=true)


