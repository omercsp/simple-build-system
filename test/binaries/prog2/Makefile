MODULE_NAME := prog2
MODULE_LANG := cpp
MODULE_OBJS := main.o
MODULE_LIBS := m
MODULE_FLAV := dbg
MODULE_CWARNS := pedantic no-variadic-macros no-gnu-zero-variadic-macro-arguments
MODULE_USE_PTHREAD := 1
MODULE_PRE_SUB_MODULES := prog2_dynlib
MODULE_LIB_DIRS := prog2_dynlib/obj/dbg
MODULE_PROJ_LIB_DIRS := lib
MODULE_LIBS := prog2_dynlib
MODULE_BIN_DEPS := prog2_dynlib/obj/dbg/libprog2_dynlib.so
MODULE_PROJECT_INCLUDE_DIRS := test/binaries/include

include ../../../module.inc.mk

