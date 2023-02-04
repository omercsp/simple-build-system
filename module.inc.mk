PROJECT_ROOT_PATH := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
SHELL := /usr/bin/bash
ECHO := /usr/bin/echo
MODULE_PATH := $(shell pwd)
MAKEFLAGS := --no-print-directory

# If no module name is defined use the directory as the name
ifeq ($(MODULE_NAME),)
MODULE_NAME := $(notdir $(MODULE_PATH))
endif

# Start with empty targets, lets see what the module's Makefile has for us
EMPTY_TARGET := __empty_target
$(EMPTY_TARGET):
	@true
CLEAN_TARGET :=$(EMPTY_TARGET)
ALL_TARGET := $(EMPTY_TARGET)

######################### Binary build start #########################
ifneq ($(MODULE_SRCS),)

CFLAGS := $(MODULE_CFLAGS) $(SBS_CFLAGS)
CDEFS := $(MODULE_CDEFS) $(SBS_CDEFS)
CWARNS := $(MODULE_CWARNS) $(SBS_CWARNS)
LDFLAGS := $(MODULE_LDFLAGS) $(SBS_LDFLAGS)

ifneq ($(MODULE_NO_DEP_FLAGS),1)
CFLAGS += -MMD -MP
endif

# Handle language
ifndef MODULE_C_SUFFIXES
MODULE_C_SUFFIXES := c C
endif

ifndef MODULE_CXX_SUFFIXES
MODULE_CXX_SUFFIXES := cpp cxx cc CC CXX CPP
endif

GCC_SUITE := gcc
CLANG_SUITE := clang

ifneq ($(MODULE_CSUITE),)
ifeq ($(filter $(MODULE_CSUITE),$(GCC_SUITE) $(CLANG_SUITE)),)
$(error Unkonwn compiler suite $(MODULE_CSUITE))
endif
else
MODULE_CSUITE := $(GCC_SUITE)
endif

ifeq ($(MODULE_CSUITE),$(GCC_SUITE))
CC := gcc
CCPP := g++
else
CC := clang
CCPP := clang++
endif

# Handle binary type
EXEC_BIN_TYPE := exec
SHARED_BIN_TYPE := shared
STATIC_BIN_TYPE := static
NONE_BIN_TYPE := none
ifeq ($(MODULE_BIN_TYPE), )
MODULE_BIN_TYPE := $(EXEC_BIN_TYPE)
endif

ifeq ($(filter $(MODULE_BIN_TYPE), $(EXEC_BIN_TYPE) $(SHARED_BIN_TYPE) $(STATIC_BIN_TYPE) $(NONE_BIN_TYPE)),)
$(error Unkonwn module type $(MODULE_BIN_TYPE))
endif

ifneq ($(filter $(MODULE_BIN_TYPE), $(EXEC_BIN_TYPE) $(SHARED_BIN_TYPE)),) # Executable or shared

LD := $(MODULE_LD)
ifeq ($(LD),)
SOURCE_SUFFIXES := $(suffix $(MODULE_SRCS))
CXX_SUFFIXES_DOT := $(addprefix .,$(MODULE_CXX_SUFFIXES))
ifeq ($(filter $(SOURCE_SUFFIXES),$(CXX_SUFFIXES_DOT)),)
LD := $(CC)
else
LD := $(CCPP)
endif
endif

OUTPUT_FLAG := -o
LD_TOOL_STR := LD

ifeq ($(MODULE_BIN_TYPE), exec)
ARTIFACT := $(MODULE_NAME)
else
LDFLAGS += -shared
CFLAGS += -fpic
ARTIFACT := lib$(MODULE_NAME).so
endif
endif # Executable or shared

# ar options:
# r - insert object to archive
# s - Add an index to the archive
# v - be verbose
# c - suppress archive creation message
ifeq ($(MODULE_BIN_TYPE), static)
LD := ar
ifeq ($(PROJECT_VERBOSE),1)
LDFLAGS := rsv
else
LDFLAGS := rsc
endif

ARTIFACT := lib$(MODULE_NAME).a
LD_TOOL_STR := AR
endif

ifeq ($(MODULE_BIN_TYPE), $(NONE_BIN_TYPE))
ARTIFACT := $(MODULE_NAME)
endif

# Handle Release/Debug specific settings
REL_FLAV := rel
DBG_FLAV := dbg
NO_FLAV := none

ifeq ($(MODULE_FLAV),)
MODULE_FLAV := $(DBG_FLAV)
endif

ifeq ($(filter $(MODULE_FLAV), $(REL_FLAV) $(DBG_FLAV) $(NO_FLAV)),)
$(error Unkonwn module flavor $(MODULE_FLAV))
endif

ifneq ($(MODULE_FLAV),none)
ifeq ($(MODULE_FLAV),$(REL_FLAV))
CFLAGS += -O3
else
CFLAGS += -g -O0
CDEFS += DEBUG=1 __DEBUG__=1
endif
endif

ifeq ($(MODULE_USE_PTHREAD),1)
CFLAGS += -pthread
ifneq ($(MODULE_BIN_TYPE), static)
LDFLAGS += -pthread
endif
endif

SRCS := $(abspath $(MODULE_SRCS))
SRCS := $(subst $(MODULE_PATH)/,,$(SRCS))

MODULE_OBJS_PATH := $(MODULE_PATH)/obj/$(MODULE_FLAV)
OBJS := $(addsuffix .o,$(strip $(SRCS)))
OBJS := $(addprefix $(MODULE_OBJS_PATH)/, $(OBJS))
OBJS_DEPS := $(OBJS:.o=.d)

ifeq ($(MODULE_ARTIFACT_DIR),)
ARTIFACT_DIR := $(MODULE_OBJS_PATH)
else
ifeq ($(MODULE_ARTIFACT_DIR_REL),1)
ARTIFACT_DIR := $(PROJECT_ROOT_PATH)/$(MODULE_ARTIFACT_DIR)
else
ARTIFACT_DIR := $(MODULE_ARTIFACT_DIR)
endif
endif

ARTIFACT := $(ARTIFACT_DIR)/$(ARTIFACT)

INCLUDE_DIRS := $(MODULE_INCLUDE_DIRS)
INCLUDE_DIRS += $(addprefix $(PROJECT_ROOT_PATH)/,$(MODULE_PROJECT_INCLUDE_DIRS))

ifeq ($(MODULE_CFLAGS_OVERRIDE),)
CFLAGS += $(addprefix -W,$(CWARNS)) $(addprefix -D,$(CDEFS)) $(addprefix -I,$(INCLUDE_DIRS))
else
CFLAGS := $(MODULE_CFLAGS_OVERRIDE)
endif

# Generate the library link flags for the build. These are generated by two
# parts. The path the libraries are looked in, and the libraries themselves.
# The library flags are separated from the link flags (LDFLAGS) since when a module
# uses a static library, it should always come _after_ the module objects, or
# an undefined reference error is issued. For dynamic libraries it doesn't
# matter.
ifneq ($(MODULE_BIN_TYPE),static)
LIB_DIRS := $(MODULE_LIB_DIRS)
LIB_DIRS += $(addprefix $(PROJECT_ROOT_PATH)/,$(MODULE_PROJECT_LIB_DIRS))
LIBS_FLAGS := $(addprefix -L,$(LIB_DIRS)) $(addprefix -l,$(MODULE_LIBS))
endif # Binary that isn't static library

# Handle linking flags overrides/additions
ifneq ($(MODULE_LDFLAGS_OVERRIDE),)
LDFLAGS := $(MODULE_LDFLAGS_OVERRIDE)
endif

# Strip the build flags. Not necessary, but creates a tighter output
CFLAGS := $(strip $(CFLAGS))
LDFLAGS := $(strip $(LDFLAGS))
LIBS_FLAGS := $(strip $(LIBS_FLAGS))

ifneq ($(filter 1,$(MODULE_VERBOSE) $(SBS_VERBOSE)),1)
Q := @
endif

# The empty target is added as an ordered dependency so the binary rule
# will always require *something* to do. This way we can suppress the 'up to date'
# messages without silencing the entire build output.
$(ARTIFACT): $(OBJS) $(MODULE_EXTERN_OBJS) $(MAKEFILE_LIST) $(MODULE_BIN_DEPS) | $(EMPTY_TARGET)
ifneq ($(MODULE_BIN_TYPE), $(NONE_BIN_TYPE))
	@mkdir -p $(ARTIFACT_DIR)
	$(if $(Q),@$(ECHO) -e "$(LD_TOOL_STR)\t$(notdir $@)")
	$(Q)$(LD) $(LDFLAGS) $(OUTPUT_FLAG) $(ARTIFACT) $(OBJS) $(MODULE_EXTERN_OBJS) $(LIBS_FLAGS)
else
.PHONY: $(ARTIFACT)
endif

# $1 - source suffix
# $2 - compiler print string (CC or CXX)
# $3 - compiler binary (gcc or g++)
# 1st rule - in-tree source files
# 2nd rule - out-of-tree source files
define CreateSourceRules
$$(MODULE_OBJS_PATH)/%.$1.o: $$(MODULE_PATH)/%.$1 $$(MAKEFILE_LIST)
	@mkdir -p $$(dir $$@)
	$$(if $$(Q),@$(ECHO) -e "$2\t$$(subst $$(MODULE_PATH)/,,$$<)")
	$$(Q)$3 $$(CFLAGS) -c $$< -o $$@

$$(MODULE_OBJS_PATH)/%.$1.o: %.$1 $$(MAKEFILE_LIST)
	@mkdir -p $$(dir $$@)
	$$(if $$(Q),@$(ECHO) -e "$2\t$$<")
	$$(Q)$3 $$(CFLAGS) -c $$< -o $$@
endef

$(foreach SUFFIX,$(MODULE_C_SUFFIXES),$(eval $(call CreateSourceRules,$(SUFFIX),CC,$(CC))))
$(foreach SUFFIX,$(MODULE_CXX_SUFFIXES),$(eval $(call CreateSourceRules,$(SUFFIX),CXX,$(CCPP))))

# Include objects dependencies settings if such exist
ifneq ($(MAKECMDGOALS),clean)
-include $(OBJS_DEPS)
endif

CLEAN_FILES := $(OBJS) $(OBJS_DEPS)
ifneq ($(MODULE_BIN_TYPE), $(NONE_BIN_TYPE))
CLEAN_FILES += $(ARTIFACT)
endif
$(ARTIFACT)_clean:
	$(Q)rm -f $(CLEAN_FILES)

ALL_TARGET := $(ARTIFACT)
CLEAN_TARGET := $(ARTIFACT)_clean

endif # None empty target
######################### Binary build end #########################

ifneq ($(MODULE_SUB_MODULES),)
$(MODULE_SUB_MODULES):
	@$(MAKE) -C $@

SUB_MODULE_CLEAN_SUFFIX := __clean
SUB_MODULES_CLEAN := $(addsuffix $(SUB_MODULE_CLEAN_SUFFIX),$(MODULE_SUB_MODULES))
$(SUB_MODULES_CLEAN):
	@$(MAKE) -C $(@:$(SUB_MODULE_CLEAN_SUFFIX)=) clean
endif

# Set the default target to 'all'. Make just picks up the first non empty
# target (or such). Here we make sure we control the make behavior.
.DEFAULT_GOAL := all
.PHONY: all clean $(CLEAN_TARGET)
.PHONY: $(MODULE_PRE_SUB_MODULES) $(MODULE_SUB_MODULES) $(MODULE_POST_SUB_MODULES) $(SUB_MODULES_CLEAN)

BUILD_ORDER := $(strip $(MODULE_PRE_BUILD) $(MODULE_PRE_SUB_MODULES))
ifneq ($(ARTIFACT),)
BUILD_ORDER := $(strip $(BUILD_ORDER) $(strip $(MODULE_NAME)))
endif
BUILD_ORDER := $(strip $(BUILD_ORDER) $(strip $(MODULE_SUB_MODULES)))
BUILD_ORDER := $(strip $(BUILD_ORDER) $(strip $(MODULE_POST_BUILD) $(MODULE_POST_SUB_MODULES)))
ifneq ($(BUILD_ORDER),$(MODULE_NAME))
ifneq ($(BUILD_ORDER),)
ORDER_STR := " order=[$(BUILD_ORDER)]"
endif
endif

all:
	@echo "Building '$(MODULE_NAME)'$(ORDER_STR)"
	@$(foreach t,$(MODULE_PRE_BUILD), $(MAKE) $(t);)
	@$(foreach t,$(MODULE_PRE_SUB_MODULES), $(MAKE) -C $(t);)
	@$(MAKE) $(ALL_TARGET) $(MODULE_SUB_MODULES)
	@$(foreach t,$(MODULE_POST_SUB_MODULES), $(MAKE) -C $(t);)
	@$(foreach t,$(MODULE_POST_BUILD), $(MAKE) $(t);)

clean:
	@echo "Cleaning '$(MODULE_NAME)'$(ORDER_STR)"
	@$(foreach t,$(MODULE_PRE_CLEAN), $(MAKE) $(t);)
	@$(foreach t,$(MODULE_PRE_SUB_MODULES), $(MAKE) -C $(t) clean;)
	@$(MAKE) $(CLEAN_TARGET) $(SUB_MODULES_CLEAN)
	@$(foreach t,$(MODULE_POST_SUB_MODULES), $(MAKE) -C $(t) clean;)
	@$(foreach t,$(MODULE_POST_CLEAN), $(MAKE) $(t);)
