.PHONY: all
all: prepare \
	regfile_test \
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
	(cd ../data && ./compile.py ori_forwarding.s ori_forwarding.txt)
	(cd ../data && ./compile.py inst_logic.s inst_logic.txt)
	(cd ../data && ./compile.py inst_shift.s inst_shift.txt)
	(cd ../data && ./compile.py inst_move.s inst_move.txt)
	(cd ../data && ./compile.py inst_simple_arith.s inst_simple_arith.txt)
	(cd ../data && ./compile.py inst_jump.s inst_jump.txt)
	(cd ../data && ./compile.py inst_br.s inst_br.txt)
	(cd ../data && ./compile.py inst_load_store.s inst_load_store.txt)
	(cd ../data && ./compile.py inst_load_stall.s inst_load_stall.txt)
	(cd ../data && ./compile.py inst_ll_sc.s inst_ll_sc.txt)

clean:
	rm -rf out/ *.vcd

%_test:
	iverilog -o out/$@ -g2009 -I.. $^

regfile_test: regfile_test.v ../regfile.v
ori_forwarding_test: ori_forwarding_test.v ../*.v
inst_shift_test: inst_shift_test.v ../*.v
inst_logic_test: inst_logic_test.v ../*.v
inst_move_test: inst_move_test.v ../*.v
inst_simple_arith_test: inst_simple_arith_test.v ../*.v
inst_jump_test: inst_jump_test.v ../*.v
inst_br_test: inst_br_test.v ../*.v
inst_load_store_test: inst_load_store_test.v ../*.v
inst_load_stall_test: inst_load_stall_test.v ../*.v
inst_ll_sc_test: inst_ll_sc_test.v ../*.v
