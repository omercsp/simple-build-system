TOP_LEVEL=$(shell git rev-parse --show-toplevel)

include ../config.mk
MODULE_OBJS := main.o cfile.o cppfile.o
MODULE_LANG := cpp
MODULE_C_SUFFIXES := c
MODULE_CXX_SUFFIXES := cpp c++

include $(TOP_LEVEL)/module.inc.mk
