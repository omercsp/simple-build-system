include ../config.mk

MODULE_NAME := dynamic
MODULE_BIN_TYPE := shared
MODULE_LANG := c
MODULE_OBJS := dynamic.o
MODULE_CDEFS += DYNLIB_DEF=10
MODULE_POST_SUB_MODULES := dynlib_tester
MODULE_VERBOSE := 1
MODULE_ARTIFACT_DIR := $(MY_PROJECT_LIB_ARTIFACT_DIR)
MODULE_ARTIFACT_DIR_REL := 1

include ../../../module.inc.mk

