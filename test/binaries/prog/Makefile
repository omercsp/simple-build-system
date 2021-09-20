include ../config.mk

MODULE_VERBOSE := 1
MODULE_NAME := prog
MODULE_SRCS := main.c
MODULE_LIBS := dynamic static
MODULE_PRE_BUILD := __pre_build
MODULE_POST_BUILD := __post_build

$(MODULE_PRE_BUILD):
	@true
$(MODULE_POST_BUILD):
	@true

include ../../../module.inc.mk

