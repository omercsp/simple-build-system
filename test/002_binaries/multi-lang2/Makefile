TOP_LEVEL=$(shell git rev-parse --show-toplevel)

include ../config.mk
C_SRCS := csrcs/file0.c
CPP_SRCS := cppsrcs/file0.cpp
MODULE_SRCS := main.c $(CPP_SRCS) $(C_SRCS)
MODULE_LANG := cpp
MODULE_C_SUFFIXES := c
MODULE_CXX_SUFFIXES := cpp c++
MODULE_INCLUDE_DIRS := $(shell pwd)
MODULE_VERBOSE := 1

include $(TOP_LEVEL)/module.inc.mk
