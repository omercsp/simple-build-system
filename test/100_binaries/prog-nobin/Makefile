include ../config.mk

NOBIN_MODULE_ABS_PATH := $(realpath $(shell pwd)/../nobin)

MODULE_NAME := prog_nobin
MODULE_SRCS := main.c ../nobin/nobin0.c $(NOBIN_MODULE_ABS_PATH)/nobin1.c
MODULE_LIBS := dynamic static

PROJ_ROOT := $(shell git rev-parse --show-toplevel)
include $(PROJ_ROOT)/module.inc.mk
