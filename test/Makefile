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
