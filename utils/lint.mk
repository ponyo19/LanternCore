VERILATOR    ?= verilator
LINT_WAIVERS ?= lint_waivers.vlt
LINT_LIST    ?=            # top:filelist pairs
TOP          ?=
FILELIST     ?=            # optional override

# All registered tops
LINT_TOPS = $(foreach u,$(LINT_LIST),$(firstword $(subst :, ,$(u))))

# Filelist for a top: $(call lint_fl,lc_core) -> ip/core/lc_hw.f
lint_fl = $(patsubst $1:%,%,$(filter $1:%,$(LINT_LIST)))

# Shared command
lint_cmd = $(VERILATOR) --lint-only -Wall --top-module $1 $(LINT_WAIVERS) -F $2

lint:
	$(if $(TOP),,$(error Set TOP=<module>. Available: $(LINT_TOPS)))
	$(eval _FL := $(or $(FILELIST),$(call lint_fl,$(TOP))))
	$(if $(_FL),,$(error Unknown TOP '$(TOP)'. Available: $(LINT_TOPS)))
	@echo "=== $(TOP) ==="
	$(call lint_cmd,$(TOP),$(_FL))

lint_all:
	@for u in $(LINT_LIST); do \
	  top=$${u%%:*}; f=$${u#*:}; \
	  echo "=== $$top ==="; \
	  $(call lint_cmd,$$top,$$f) || exit 1; \
	done

lint_list:
	@echo $(LINT_TOPS)

.PHONY: lint lint_all lint_list