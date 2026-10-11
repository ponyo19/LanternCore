# Makefile
SIM = verilator
TOPLEVEL_LANG = verilog

VERILOG_SOURCES += $(PWD)/../../rtl/lc_pkg.sv
VERILOG_SOURCES += $(PWD)/../../rtl/lc_imm_gen.sv
VERILOG_SOURCES += $(PWD)/../../rtl/lc_decoder.sv


TOPLEVEL = lc_decoder

COCOTB_TEST_MODULES = test_decoder

export WAVES=1

include $(shell cocotb-config --makefiles)/Makefile.sim