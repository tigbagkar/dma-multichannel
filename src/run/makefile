.PHONY: compile elaborate lint clean

compile:
	vlog -sv -f files.f

elaborate: compile
	vsim -c placeholder_tb -do "quit -f"

lint:
	verilator --lint-only -Wall -Wno-fatal -f files.f

clean:
	rm -rf work
	rm -f transcript vsim.wlf