.PHONY: compile test clean

compile:
	vlog -sv -mfcu -f files.f

test: compile
	vsim -c tb_top +UVM_TESTNAME=config_path_test -do "run -all; quit"

clean:
	rm -rf work
	rm -f transcript vsim.wlf