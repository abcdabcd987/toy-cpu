.PHONY: all
all: prepare memory_test alu_test

prepare:
	mkdir -p out

clean:
	rm -rf out/

%_test:
	iverilog -o out/$@ -g2009 $^

memory_test: memory_test.v ../memory.v
alu_test: alu_test.v ../alu.v
