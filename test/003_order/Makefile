MODULE_NAME := order
MODULE_PRE_SUB_MODULES := pre_order0 pre_order1
MODULE_SUB_MODULES := unordered0 unordered1 unordered2 before_unordered after_unordered
MODULE_POST_SUB_MODULES := post_order0 post_order1

unordered0 unordered1 unordered2: before_unordered
after_unordered: unordered0 unordered1 unordered2

PROJ_ROOT := $(shell git rev-parse --show-toplevel)
include $(PROJ_ROOT)/module.inc.mk
