include ../config.mk

MODULE_VERBOSE := 0
MODULE_NAME := prog-with-out-of-tree-src
MODULE_SRCS := main.c ../out-of-tree-src/out-of-tree-src.c

PROJ_ROOT := $(shell git rev-parse --show-toplevel)
include $(PROJ_ROOT)/module.inc.mk
