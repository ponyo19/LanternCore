VERILATOR     ?= verilator
LINT_WAIVERS  ?= lint_waivers.vlt
LINT_FILELIST ?=            # filelist to lint all modules from
TOP           ?=

# All modules declared in the .v/.sv files of the filelist
_srcs     = $(addprefix $(dir $(LINT_FILELIST)),$(filter %.v %.sv,$(shell sed 's://.*::' $(LINT_FILELIST))))
LINT_TOPS = $(shell sed -nE 's/^\s*module\s+(\w+).*/\1/p' $(_srcs))

lint_cmd = $(VERILATOR) --lint-only -Wall --top-module $1 $(LINT_WAIVERS) -F $(LINT_FILELIST)

lint:
	$(if $(TOP),,$(error Set TOP=<module>. Available: $(LINT_TOPS)))
	$(call lint_cmd,$(TOP))

lint_all:
	@for top in $(LINT_TOPS); do \
	  echo "=== $$top ==="; \
	  $(call lint_cmd,$$top) || exit 1; \
	done

lint_list:
	@echo $(LINT_TOPS)

.PHONY: lint lint_all lint_list