# Run each test suite's Makefile under ip/core/tests.
TESTS_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../ip/core/tests)
TEST_MAKEFILES := $(wildcard $(TESTS_DIR)/*/Makefile)
TEST_DIRS := $(patsubst %/Makefile,%,$(TEST_MAKEFILES))

test_all:
	@if [ -z "$(TEST_MAKEFILES)" ]; then \
		echo "No test Makefiles found under $(TESTS_DIR)" >&2; \
		exit 1; \
	fi
	@status=0; \
	for dir in $(TEST_DIRS); do \
		echo "==> Running tests in $$dir"; \
		$(MAKE) -C "$$dir" || status=$$?; \
	done; \
	exit $$status

.PHONY: test_all