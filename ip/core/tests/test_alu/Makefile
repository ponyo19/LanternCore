# Makefile
SIM = verilator
TOPLEVEL_LANG = verilog

VERILOG_SOURCES += $(CURDIR)/../../rtl/lc_pkg.sv
VERILOG_SOURCES += $(CURDIR)/../../rtl/lc_alu.sv


TOPLEVEL = lc_alu

COCOTB_TEST_MODULES = test_alu

export WAVES=1

include $(shell cocotb-config --makefiles)/Makefile.sim
