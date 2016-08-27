.PHONY: all
all: prepare memory_test alu_test regfile_test ori_test

prepare:
	mkdir -p out

clean:
	rm -rf out/

%_test:
	iverilog -o out/$@ -g2009 $^

memory_test: memory_test.v ../memory.v
alu_test: alu_test.v ../alu.v
regfile_test: regfile_test.v ../regfile.v
ori_test: ori_test.v ../*.v
