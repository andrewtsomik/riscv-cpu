SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += ../rtl/risc_pkg.sv ../rtl/pc_register.sv ../rtl/register_file.sv ../rtl/instruct_mem.sv ../rtl/decoder.sv ../rtl/immediate_gen.sv ../rtl/alu.sv ../rtl/data_mem.sv ../rtl/cpu_top.sv

TOPLEVEL = cpu_top
MODULE = test_cpu_top

include $(shell cocotb-config --makefiles)/Makefile.sim
