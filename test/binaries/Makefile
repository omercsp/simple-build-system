MODULE_PRE_SUB_MODULES := dynlib staticlib
MODULE_SUB_MODULES := prog
MODULE_POST_SUB_MODULES := prog2

staticlib: dynlib

test:
	@test/run_test.sh
.PHONY: test

include ../../module.inc.mk
