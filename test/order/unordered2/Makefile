MODULE_NAME := "Unordered002"
MODULE_POST_BUILD := sleeper

empty:
	@:

sleeper: empty
	$(shell sleep  0.0$$(($$RANDOM % 10)))
	@echo "Done building $(MODULE_NAME)"

include ../../../module.inc.mk
