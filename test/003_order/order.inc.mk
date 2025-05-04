pre:
	@echo "Starting $(SBS_MODULE_NAME)"
	@$(shell sleep  0.0$$(($$RANDOM % 10)))
post:
	@$(shell sleep  0.0$$(($$RANDOM % 10)))
	@echo "Finished $(SBS_MODULE_NAME)"

.PHONY: sleeper

MODULE_PRE_BUILD := pre
MODULE_POST_BUILD := post

PROJ_ROOT := $(shell git rev-parse --show-toplevel)
include $(PROJ_ROOT)/module.inc.mk
