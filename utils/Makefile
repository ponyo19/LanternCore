# Filelists in dependency order
LINT_FILELISTS := ../ip/interconnect/OBI/obi_hw.f ../ip/core/lc_hw.f 

include lint.mk
include autotest.mk

ci: lint_all test_all
.PHONY: ci