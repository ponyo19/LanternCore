VERILATOR      ?= verilator
LINT_WAIVERS   ?= lint_waivers.vlt

LINT_FILELIST  ?=
LINT_FILELISTS ?= $(LINT_FILELIST)
TOP            ?=

# $1 = filelist -> .v/.sv sources it lists (paths relative to the filelist)
srcs_of = $(addprefix $(dir $1),$(filter %.v %.sv,$(shell sed 's://.*::' $1)))
# $1 = filelist -> modules declared in its sources
tops_of = $(if $(call srcs_of,$1),$(shell sed -nE 's/^\s*module\s+(\w+).*/\1/p' $(call srcs_of,$1)))
LINT_TOPS = $(sort $(foreach f,$(LINT_FILELISTS),$(call tops_of,$f)))

# $1 = top module
lint_cmd = $(VERILATOR) --lint-only -Wall --top-module $1 $(LINT_WAIVERS) $(addprefix -F ,$(LINT_FILELISTS))

lint:
	$(if $(TOP),,$(error Set TOP=<module>. Available: $(LINT_TOPS)))
	$(if $(filter $(TOP),$(LINT_TOPS)),,$(error Module '$(TOP)' not found in: $(LINT_FILELISTS)))
	$(call lint_cmd,$(TOP))

lint_all:
	@$(foreach f,$(LINT_FILELISTS), \
	  for top in $(call tops_of,$f); do \
	    echo "=== $f: $$top ==="; \
	    $(call lint_cmd,$$top) || exit 1; \
	  done;)

lint_list:
	@$(foreach f,$(LINT_FILELISTS),echo "$f: $(call tops_of,$f)";)

.PHONY: lint lint_all lint_list