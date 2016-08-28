.PHONY: all
all: prepare memory_test regfile_test ori_forwarding_test inst_shift_test inst_logic_test

prepare:
	mkdir -p out
	(cd ../data && ./compile.py ori_forwarding.s ori_forwarding.txt)
	(cd ../data && ./compile.py inst_logic.s inst_logic.txt)
	(cd ../data && ./compile.py inst_shift.s inst_shift.txt)

clean:
	rm -rf out/ *.vcd

%_test:
	iverilog -o out/$@ -g2009 -I.. $^

memory_test: memory_test.v ../memory.v
regfile_test: regfile_test.v ../regfile.v
ori_forwarding_test: ori_forwarding_test.v ../*.v
inst_shift_test: inst_shift_test.v ../*.v
inst_logic_test: inst_logic_test.v ../*.v
