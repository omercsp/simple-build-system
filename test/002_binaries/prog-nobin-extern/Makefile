include ../config.mk

MODULE_SRCS := main.c
FLAV=$(MODULE_FLAV)

ifeq ($(FLAV),)
FLAV=dbg
endif

MODULE_EXTERN_OBJS := ../nobin/obj/$(FLAV)/nobin0.c.o ../nobin/obj/$(FLAV)/nobin1.c.o
# External objects might or might not be built in the same project. They are
# added as dependencies to the module build. In this case, since they are built
# by another module int the same project, we need to make sure that module is
# built beforehand. This requires the following two lines. Adding a pre sub
# module to the module build isn't enough as the external objects are being
# evaluated before the artifact is linked, hence the 2nd line, which adds a
# dependency between these objects and pre sub module, preventing the module
# artifact from being built before the external objects are created.
MODULE_PRE_SUB_MODULES := ../nobin
$(MODULE_EXTERN_OBJS): $(MODULE_PRE_SUB_MODULES)

PROJ_ROOT := $(shell git rev-parse --show-toplevel)
include $(PROJ_ROOT)/module.inc.mk
