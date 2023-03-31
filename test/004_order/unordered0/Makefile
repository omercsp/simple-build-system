MODULE_NAME := "Unordered000"
MODULE_POST_BUILD := sleeper

empty:
	@:

sleeper: empty
	$(shell sleep  0.0$$(($$RANDOM % 10)))
	@echo "Done building $(MODULE_NAME)"

PROJ_ROOT := $(shell git rev-parse --show-toplevel)
include $(PROJ_ROOT)/module.inc.mk
