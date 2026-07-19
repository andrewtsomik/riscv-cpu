SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += ../rtl/risc_pkg.sv ../rtl/instruct_mem.sv

TOPLEVEL = instruct_mem
MODULE = test_instruct_mem

include $(shell cocotb-config --makefiles)/Makefile.sim
