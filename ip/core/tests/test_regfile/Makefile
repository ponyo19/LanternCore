# Makefile
SIM = verilator
TOPLEVEL_LANG = verilog

VERILOG_SOURCES += $(CURDIR)/../../rtl/lc_pkg.sv
VERILOG_SOURCES += $(CURDIR)/../../rtl/lc_regfile.sv


TOPLEVEL = lc_regfile

COCOTB_TEST_MODULES = test_regfile

export WAVES=1

include $(shell cocotb-config --makefiles)/Makefile.sim