MODULE_NAME := binaries
MODULE_SUB_MODULES := dynlib staticlib nobin multi-lang prog
MODULE_SUB_MODULES += multi-lang2 prog-with-out-of-tree-src
MODULE_SUB_MODULES += prog2 prog-nobin prog-nobin-extern

prog prog-nobin: dynlib staticlib
staticlib: dynlib
prog-nobin-extern: prog-nobin

PROJ_ROOT=$(shell git rev-parse --show-toplevel)
include $(PROJ_ROOT)/module.inc.mk
