.PHONY: all
all: prepare memory_test alu_test regfile_test ori_forwarding_test

prepare:
	mkdir -p out

clean:
	rm -rf out/ *.vcd

%_test:
	iverilog -o out/$@ -g2009 $^

memory_test: memory_test.v ../memory.v
alu_test: alu_test.v ../alu.v
regfile_test: regfile_test.v ../regfile.v
ori_forwarding_test: ori_forwarding_test.v ../*.v
	(cd ../data && ./compile.py ori_forwarding.s ori_forwarding.txt)
