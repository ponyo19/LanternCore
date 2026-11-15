# Makefile
SIM = verilator
TOPLEVEL_LANG = verilog

VERILOG_SOURCES += $(CURDIR)/../../rtl/lc_pkg.sv
VERILOG_SOURCES += $(CURDIR)/../../rtl/lc_branch_unit.sv


TOPLEVEL = lc_branch_unit

COCOTB_TEST_MODULES = test_branch_unit

export WAVES=1

include $(shell cocotb-config --makefiles)/Makefile.sim