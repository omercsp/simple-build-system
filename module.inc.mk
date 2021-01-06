PROJECT_ROOT_PATH := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
MODULE_PATH := $(shell pwd)
MAKEFLAGS := --no-print-directory
-include $(PROJECT_ROOT_PATH)/config.mk

# If no module name was definedm use the directory as the name
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
ifneq ($(MODULE_OBJS),)

CFLAGS := $(MODULE_CFLAGS) $(SBS_CFLAGS)
ifneq ($(MODULE_IGNORE_PROJECT_CFLAGS),1)
CFLAGS := $(PROJECT_CFLAGS) $(CFLAGS)
endif

CDEFS := $(MODULE_CDEFS) $(SBS_CDEFS)
ifneq ($(MODULE_IGNORE_PROJECT_CDEFS),1)
CDEFS := $(PROJECT_CDEFS) $(CDEFS)
endif

CWARNS := $(MODULE_CWARNS) $(SBS_CWARNS)
ifneq ($(MODULE_IGNORE_PROJECT_CWARNS),1)
CWARNS := $(PROJECT_CWARNS) $(CWARNS)
endif

LDFLAGS := $(MODULE_LDFLAGS) $(SBS_LDFLAGS)
ifneq ($(MODULE_IGNORE_PROJECT_LDFLAGS),1)
LDFLAGS := $(PROJECT_LDFLAGS) $(LDFLAGS)
endif

ifneq ($(MODULE_NO_DEP_FLAGS),1)
CFLAGS += -MMD -MP
endif

# Handle language
C_LANG := c
CPP_LANG := cpp
ifeq ($(MODULE_LANG),)
MODULE_LANG := $(C_LANG)
endif
ifeq ($(filter $(MODULE_LANG), $(C_LANG) $(CPP_LANG)),)
$(error Unkonwn module language $(MODULE_LANG))
endif

ifeq ($(MODULE_LANG),cpp)
CC := g++
SRC_SUFFIX := cpp
else
CC := gcc
SRC_SUFFIX := c
endif

# Handle binary type
EXEC_BIN_TYPE := exec
SHARED_BIN_TYPE := shared
STATIC_BIN_TYPE := static
ifeq ($(MODULE_BIN_TYPE), )
MODULE_BIN_TYPE := $(EXEC_BIN_TYPE)
endif

ifeq ($(filter $(MODULE_BIN_TYPE), $(EXEC_BIN_TYPE) $(SHARED_BIN_TYPE) $(STATIC_BIN_TYPE)),)
$(error Unkonwn module type $(MODULE_BIN_TYPE))
endif

ifeq ($(MODULE_BIN_TYPE), exec)
LD := $(CC)
OUTPUT_FLAG := -o
BIN := $(MODULE_NAME)
LD_TOOL_STR := LD
endif

ifeq ($(MODULE_BIN_TYPE), shared)
LD=$(CC)
LDFLAGS += -shared
CFLAGS += -fpic
OUTPUT_FLAG := -o
BIN := lib$(MODULE_NAME).so
LD_TOOL_STR := LD
endif

# ar options:
# r - insert object to archive
# s - Add an index to the archive
# v - be verobse
# c - suprees archive creation message
ifeq ($(MODULE_BIN_TYPE), static)
LD := ar
ifeq ($(PROJECT_VERBOSE),1)
LDFLAGS := rsv
else
LDFLAGS := rsc
endif

BIN := lib$(MODULE_NAME).a
LD_TOOL_STR := AR
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

MODULE_OBJS_PATH := $(MODULE_PATH)/obj/$(MODULE_FLAV)
OBJS := $(addprefix $(MODULE_OBJS_PATH)/, $(strip $(MODULE_OBJS)))
OBJS_DEPS := $(OBJS:.o=.d)
BIN := $(MODULE_OBJS_PATH)/$(BIN)

INCLUDE_DIRS := $(MODULE_INCLUDE_DIRS)
ifneq ($(MODULE_IGNORE_PROJECT_INCLUDE_DIRS),1)
INCLUDE_DIRS += $(addprefix $(PROJECT_ROOT_PATH)/,$(PROJECT_INCLUDE_DIRS))
endif

INCLUDE_DIRS += $(MODULE_ABS_INCLUDE_DIRS)
ifneq ($(MODULE_IGNORE_PROJECT_ABS_INCLUDE_DIRS),1)
INCLUDE_DIRS += $(PROJECT_ABS_INCLUDE_DIRS)
endif

ifeq ($(MODULE_CFLAGS_OVERRIDE),)
CFLAGS += $(addprefix -W,$(CWARNS)) $(addprefix -D,$(CDEFS)) $(addprefix -I,$(INCLUDE_DIRS))
else
CFLAGS := $(MODULE_CFLAGS_OVERRIDE)
endif

# Generate the library link flags for the build. These are generated by two
# parts. The path the libraries are looked in, and the libraries themselves.
# The libs flags are seperated from the link flags (LDFLAGS) since when a module
# uses a static library, it should alwasy come _after_ the module objects, or
# an undefined reference error is issued. For dynamic libraries it doesn't
# matter.
ifneq ($(MODULE_BIN_TYPE),static)
LIB_DIRS := $(MODULE_LIB_DIRS)
ifneq ($(MODULE_IGNORE_PROJECT_LIB_DIRS),1)
LIB_DIRS += $(addprefix $(PROJECT_ROOT_PATH)/,$(PROJECT_LIB_DIRS))
endif
LIB_DIRS += $(MODULE_ABS_LIB_DIRS)
ifneq ($(MODULE_IGNORE_PROJECT_ABS_LIB_DIRS),1)
LIB_DIRS += $(PROJECT_ABS_LIB_DIRS)
endif
LIBS_FLAGS := $(addprefix -L,$(LIB_DIRS)) $(addprefix -l,$(MODULE_LIBS))
endif # Binary that isn't static libraray

# Handle linking flags overrides/additions
ifneq ($(MODULE_LDLAGS_OVERRIDE),)
LDFLAGS := $(MODULE_LDFLAGS_OVERRIDE)
endif

# Strip the build flags. Not necessary, but creates a tighter output
CFLAGS := $(strip $(CFLAGS))
LDFLAGS := $(strip $(LDFLAGS))
LIBS_FLAGS := $(strip $(LIBS_FLAGS))


ifneq ($(filter 1,$(PROJECT_VERBOSE) $(MODULE_VERBOSE) $(SBS_VERBOSE)),1)
Q := @
endif

# The empty target is added as an ordered dependency so the binary rule
# will always require *something* to do. This way we can suprees the 'up to date'
# messages without silencing the entire build output.
$(BIN): $(OBJS) $(MAKEFILE_LIST) $(MODULE_BIN_DEPS) | $(EMPTY_TARGET)
	$(if $(Q),@echo "$(LD_TOOL_STR) $(notdir $@)")
	$(Q)$(LD) $(LDFLAGS) $(OUTPUT_FLAG) $(BIN) $(OBJS) $(LIBS_FLAGS)

$(MODULE_OBJS_PATH)/%.o: $(MODULE_PATH)/%.$(SRC_SUFFIX) $(MAKEFILE_LIST)
	@mkdir -p $(dir $@)
	$(if $(Q),@echo "CC $(notdir $@)")
	$(Q)$(CC) $(CFLAGS) -c $< -o $@

# Include objects dependencies settings if such exist
ifneq ($(MAKECMDGOALS),clean)
-include $(OBJS_DEPS)
endif

$(BIN)_clean:
	$(Q)rm -f $(BIN) $(OBJS) $(OBJS_DEPS)

ALL_TARGET := $(BIN)
CLEAN_TARGET := $(BIN)_clean

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
# target (or such). Here we make sure we control the make behaviour
.DEFAULT_GOAL := all
.PHONY: all clean $(CLEAN_TARGET)
.PHONY: $(MODULE_PRE_SUB_MODULES) $(MODULE_SUB_MODULES) $(MODULE_POST_SUB_MODULES) $(SUB_MODULES_CLEAN)

BUILD_ORDER := $(strip $(MODULE_PRE_BUILD) $(MODULE_PRE_SUB_MODULES))
BUILD_ORDER := $(strip $(BUILD_ORDER) $(strip $(MODULE_NAME) $(MODULE_SUB_MODULES)))
BUILD_ORDER := $(strip $(BUILD_ORDER) $(strip $(MODULE_POST_BUILD) $(MODULE_POST_SUB_MODULES)))
ifneq ($(BUILD_ORDER),$(MODULE_NAME))
ORDER_STR := " order=[$(BUILD_ORDER)]"
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
