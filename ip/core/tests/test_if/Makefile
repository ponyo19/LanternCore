VERILATOR_TRACE = 1
.DEFAULT_GOAL := sim

SIM = verilator
TOPLEVEL_LANG = verilog

VERILOG_SOURCES += $(CURDIR)/../../rtl/lc_pkg.sv
VERILOG_SOURCES += $(CURDIR)/../../../interconnect/OBI/rtl/obi_pkg.sv
VERILOG_SOURCES += $(CURDIR)/../../rtl/lc_if.sv
VERILOG_SOURCES += $(CURDIR)/../../rtl/lc_pc_rom.sv
VERILOG_SOURCES += $(CURDIR)/if_tb.sv


TOPLEVEL = if_tb

COCOTB_TEST_MODULES = test_if

test_rom.hex: test_if.py
	python3 test_if.py
	test -s test_rom.hex

.PHONY: rom
rom: test_rom.hex

# Generate ROM before simulation
sim: test_rom.hex
CUSTOM_SIM_DEPS += test_rom.hex

export WAVES=1

include $(shell cocotb-config --makefiles)/Makefile.sim
