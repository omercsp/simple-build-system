include ../config.mk

MODULE_VERBOSE := 1
MODULE_NAME := prog
MODULE_OBJS := main.o
MODULE_LIBS := static dynamic
MODULE_FLAV := dbg
MODULE_BIN_DEPS := ../nobin/obj/$(MODULE_FLAV)/object.o
MODULE_PRE_BUILD := __pre_build
MODULE_POST_BUILD := __post_build

$(MODULE_PRE_BUILD):
	@true
$(MODULE_POST_BUILD):
	@true

include ../../../module.inc.mk

