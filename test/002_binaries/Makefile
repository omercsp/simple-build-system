MODULE_NAME := binaries
MODULE_PRE_SUB_MODULES := dynlib staticlib nobin multi-lang
MODULE_SUB_MODULES := prog multi-lang2 prog-with-out-of-tree-src
MODULE_POST_SUB_MODULES := prog2 prog-nobin prog-nobin-extern

staticlib: dynlib
multi-lang2: prog
prog-with-out-of-tree-src: multi-lang2
multi-lang2__clean: prog__clean
prog-with-out-of-tree-src__clean: multi-lang2__clean

PROJ_ROOT=$(shell git rev-parse --show-toplevel)
include $(PROJ_ROOT)/module.inc.mk
