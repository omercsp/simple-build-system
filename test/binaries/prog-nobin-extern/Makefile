include ../config.mk

MODULE_VERBOSE := 1
MODULE_SRCS := main.c
FLAV=$(MODULE_FLAV)

ifeq ($(FLAV),)
FLAV=dbg
endif

MODULE_EXTERN_OBJS := ../nobin/obj/$(FLAV)/nobin0.c.o ../nobin/obj/$(FLAV)/nobin1.c.o

include ../../../module.inc.mk

