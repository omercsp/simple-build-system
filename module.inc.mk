# Simple Build System, written by Omer Caspi
# https://github.com/omercsp/simple-build-system

SBS_PROJ_ROOT := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
SHELL := /usr/bin/bash
ECHO := /usr/bin/echo
MAKEFLAGS := --no-print-directory
SBS_MODULE_PATH := $(shell pwd)
SBS_BASE_MAKEFILE := $(firstword $(MAKEFILE_LIST))
SBS_VERSION := 0.5.1

# If no module name is defined use the directory as the name
SBS_MODULE_NAME := $(MODULE_NAME)
ifeq ($(SBS_MODULE_NAME),)
SBS_MODULE_NAME := $(notdir $(SBS_MODULE_PATH))
endif

# Start with empty targets, lets see what the module's Makefile has for us
SBS_EMPTY_TARGET := sbs_empty_target
$(SBS_EMPTY_TARGET):
	@true
SBS_CLEAN_TARGET := $(SBS_EMPTY_TARGET)
SBS_MAIN_TARGET := $(SBS_EMPTY_TARGET)

######################### Binary build start #########################
ifneq ($(MODULE_SRCS),)

SBS_CFLAGS := $(MODULE_CFLAGS)
SBS_CDEFS := $(MODULE_CDEFS)
SBS_CWARNS := $(MODULE_CWARNS)
SBS_LDFLAGS := $(MODULE_LDFLAGS)

ifneq ($(MODULE_DEP_FLAGS),0)
SBS_CFLAGS += -MMD -MP
endif

# Handle language
SBS_C_SUFFIXES := $(MODULE_C_SUFFIXES)
ifndef SBS_C_SUFFIXES
SBS_C_SUFFIXES := c C
endif

SBS_CXX_SUFFIXES := $(MODULE_CXX_SUFFIXES)
ifndef SBS_CXX_SUFFIXES
SBS_CXX_SUFFIXES := cpp cxx cc CC CXX CPP
endif

SBS_GCC_SUITE := gcc
SBS_CLANG_SUITE := clang

SBS_CSUITE := $(MODULE_CSUITE)
ifneq ($(SBS_CSUITE),)
ifeq ($(filter $(SBS_CSUITE),$(SBS_GCC_SUITE) $(SBS_CLANG_SUITE)),)
$(error Unkonwn compiler suite $(SBS_CSUITE))
endif
else
SBS_CSUITE := $(SBS_GCC_SUITE)
endif

ifeq ($(SBS_CSUITE),$(SBS_GCC_SUITE))
SBS_CC := gcc
SBS_CCPP := g++
else
SBS_CC := clang
SBS_CCPP := clang++
endif

# Handle binary type
SBS_EXEC_BIN_TYPE := exec
SBS_SHARED_BING_TYPE := shared
SBS_STATIC_BIN_TYPE := static
SBS_NONE_BIN_TYPE := none
SBS_BIN_TYPE := $(MODULE_BIN_TYPE)
ifeq ($(SBS_BIN_TYPE), )
SBS_BIN_TYPE := $(SBS_EXEC_BIN_TYPE)
endif

ifeq ($(filter $(SBS_BIN_TYPE), $(SBS_EXEC_BIN_TYPE) $(SBS_SHARED_BING_TYPE) $(SBS_STATIC_BIN_TYPE) $(SBS_NONE_BIN_TYPE)),)
$(error Unkonwn module type $(SBS_BIN_TYPE))
endif

ifneq ($(filter $(SBS_BIN_TYPE), $(SBS_EXEC_BIN_TYPE) $(SBS_SHARED_BING_TYPE)),) # Executable or shared

SBS_LD := $(MODULE_LD)
ifeq ($(SBS_LD),)
SBS_SRC_SUFFIXES := $(suffix $(MODULE_SRCS))
SBS_CXX_SUFFIXES_DOT := $(addprefix .,$(SBS_CXX_SUFFIXES))
ifeq ($(filter $(SBS_SRC_SUFFIXES),$(SBS_CXX_SUFFIXES_DOT)),)
SBS_LD := $(SBS_CC)
else
SBS_LD := $(SBS_CCPP)
endif
endif

SBS_OUTPUT_FLAG := -o
SBS_LD_STR := LD

ifeq ($(SBS_BIN_TYPE), $(SBS_EXEC_BIN_TYPE))
SBS_ARTIFACT := $(SBS_MODULE_NAME)
else
SBS_LDFLAGS += -shared
SBS_CFLAGS += -fpic
SBS_ARTIFACT := lib$(SBS_MODULE_NAME).so
endif
endif # Executable or shared

# ar options:
# r - insert object to archive
# s - Add an index to the archive
# v - be verbose
# c - suppress archive creation message
ifeq ($(SBS_BIN_TYPE), $(SBS_STATIC_BIN_TYPE))
SBS_LD := ar
ifeq ($(MODULE_VERBOSE),1)
SBS_LDFLAGS := -rscv
else
SBS_LDFLAGS := -rsc
endif

SBS_ARTIFACT := lib$(SBS_MODULE_NAME).a
SBS_LD_STR := AR
endif

ifeq ($(SBS_BIN_TYPE), $(SBS_NONE_BIN_TYPE))
SBS_ARTIFACT := $(SBS_MODULE_NAME)
endif

# Handle Release/Debug specific settings
SBS_REL_FLAV := rel
SBS_DBG_FLAV := dbg

SBS_FLAV := $(MODULE_FLAV)
ifeq ($(SBS_FLAV),)
SBS_FLAV := $(SBS_DBG_FLAV)
endif

ifneq ($(words $(SBS_FLAV)), 1)
$(error Invalid flavor '$(SBS_FLAV)')
endif

SBS_USE_DEF_FLAV := $(MODULE_USE_DEF_FLAV)
ifeq ($(SBS_USE_DEF_FLAV),)
SBS_USE_DEF_FLAV := 1
endif
ifeq ($(filter $(SBS_USE_DEF_FLAV),1 0),)
$(error Illegal default flavor options setting '$(SBS_USE_DEF_FLAV)')
endif

ifneq ($(filter $(SBS_FLAV),$(SBS_REL_FLAV) $(SBS_DBG_FLAV)),)
ifneq ($(SBS_USE_DEF_FLAV),0)
ifeq ($(SBS_FLAV),$(SBS_REL_FLAV))
SBS_CFLAGS += -O3
else
SBS_CFLAGS += -g -O0
SBS_CDEFS += DEBUG=1 __DEBUG__=1
endif
endif
endif

ifeq ($(MODULE_USE_PTHREAD),1)
SBS_CFLAGS += -pthread
ifneq ($(SBS_BIN_TYPE), $(SBS_STATIC_BIN_TYPE))
SBS_LDFLAGS += -pthread
endif
endif

SBS_SRCS := $(abspath $(MODULE_SRCS))
SBS_SRCS := $(subst $(SBS_MODULE_PATH)/,,$(SBS_SRCS))

SBS_OBJS_PATH := $(SBS_MODULE_PATH)/obj/$(SBS_FLAV)
SBS_OBJS := $(addsuffix .o,$(strip $(SBS_SRCS)))
SBS_OBJS := $(addprefix $(SBS_OBJS_PATH)/, $(SBS_OBJS))
SBS_OBJS_DEPS := $(SBS_OBJS:.o=.d)

ifeq ($(MODULE_ARTIFACT_DIR),)
SBS_ARTIFACT_DIR := $(SBS_OBJS_PATH)
else
ifeq ($(MODULE_ARTIFACT_DIR_REL),1)
SBS_ARTIFACT_DIR := $(SBS_PROJ_ROOT)/$(MODULE_ARTIFACT_DIR)
else
SBS_ARTIFACT_DIR := $(MODULE_ARTIFACT_DIR)
endif
endif

SBS_ARTIFACT := $(SBS_ARTIFACT_DIR)/$(SBS_ARTIFACT)

SBS_INC_DIRS := $(MODULE_INCLUDE_DIRS)
SBS_INC_DIRS += $(addprefix $(SBS_PROJ_ROOT)/,$(MODULE_PROJECT_INCLUDE_DIRS))

ifeq ($(MODULE_CFLAGS_OVERRIDE),)
SBS_CFLAGS += $(addprefix -W,$(SBS_CWARNS)) $(addprefix -D,$(SBS_CDEFS)) $(addprefix -I,$(SBS_INC_DIRS))
else
SBS_CFLAGS := $(MODULE_CFLAGS_OVERRIDE)
endif

# Generate the library link flags for the build. These are generated by two
# parts. The path the libraries are looked in, and the libraries themselves.
# The library flags are separated from the link flags (SBS_LDFLAGS) since when a module
# uses a static library, it should always come _after_ the module objects, or
# an undefined reference error is issued. For dynamic libraries it doesn't
# matter.
ifneq ($(SBS_BIN_TYPE),$(SBS_STATIC_BIN_TYPE))
SBS_LIB_DIRS := $(MODULE_LIB_DIRS)
SBS_LIB_DIRS += $(addprefix $(SBS_PROJ_ROOT)/,$(MODULE_PROJECT_LIB_DIRS))
SBS_LIBS_FLAGS := $(addprefix -L,$(SBS_LIB_DIRS)) $(addprefix -l,$(MODULE_LIBS))
endif # Binary that isn't static library

# Handle linking flags overrides/additions
ifneq ($(MODULE_LDFLAGS_OVERRIDE),)
SBS_LDFLAGS := $(MODULE_LDFLAGS_OVERRIDE)
endif

# Strip the build flags. Not necessary, but creates a tighter output
SBS_CFLAGS := $(strip $(SBS_CFLAGS))
SBS_LDFLAGS := $(strip $(SBS_LDFLAGS))
SBS_LIBS_FLAGS := $(strip $(SBS_LIBS_FLAGS))

ifneq ($(filter 1,$(MODULE_VERBOSE)),1)
SBS_Q := @
endif

# The empty target is added as an ordered dependency so the binary rule
# will always require *something* to do. This way we can suppress the 'up to date'
# messages without silencing the entire build output.
$(SBS_ARTIFACT): $(SBS_OBJS) $(MODULE_EXTERN_OBJS) $(MAKEFILE_LIST) $(MODULE_BIN_DEPS) | $(SBS_EMPTY_TARGET)
ifneq ($(SBS_BIN_TYPE), $(SBS_NONE_BIN_TYPE))
	@mkdir -p $(SBS_ARTIFACT_DIR)
	$(if $(SBS_Q),@$(ECHO) -e "$(SBS_LD_STR)\t$(notdir $@)")
	$(SBS_Q)$(SBS_LD) $(SBS_LDFLAGS) $(SBS_OUTPUT_FLAG) $(SBS_ARTIFACT) $(SBS_OBJS) $(MODULE_EXTERN_OBJS) $(SBS_LIBS_FLAGS)
else
.PHONY: $(SBS_ARTIFACT)
endif

# $1 - source suffix
# $2 - compiler print string (SBS_CC or CXX)
# $3 - compiler binary (gcc or g++)
# 1st rule - in-tree source files
# 2nd rule - out-of-tree source files
define CreateSourceRules
$$(SBS_OBJS_PATH)/%.$1.o: $$(SBS_MODULE_PATH)/%.$1 $$(MAKEFILE_LIST)
	@mkdir -p $$(dir $$@)
	$$(if $$(SBS_Q),@$(ECHO) -e "$2\t$$(subst $$(SBS_MODULE_PATH)/,,$$<)")
	$$(SBS_Q)$3 $$(SBS_CFLAGS) -c $$< -o $$@

$$(SBS_OBJS_PATH)/%.$1.o: %.$1 $$(MAKEFILE_LIST)
	@mkdir -p $$(dir $$@)
	$$(if $$(SBS_Q),@$(ECHO) -e "$2\t$$<")
	$$(SBS_Q)$3 $$(SBS_CFLAGS) -c $$< -o $$@
endef

$(foreach SUFFIX,$(SBS_C_SUFFIXES),$(eval $(call CreateSourceRules,$(SUFFIX),CC,$(SBS_CC))))
$(foreach SUFFIX,$(SBS_CXX_SUFFIXES),$(eval $(call CreateSourceRules,$(SUFFIX),CXX,$(SBS_CCPP))))

# Include objects dependencies settings if such exist
ifneq ($(MAKECMDGOALS),clean)
-include $(SBS_OBJS_DEPS)
endif

SBS_CLEAN_FILES := $(SBS_OBJS) $(SBS_OBJS_DEPS)
ifneq ($(SBS_BIN_TYPE), $(SBS_NONE_BIN_TYPE))
SBS_CLEAN_FILES += $(SBS_ARTIFACT)
endif
$(SBS_ARTIFACT)_clean:
	$(SBS_Q)rm -f $(SBS_CLEAN_FILES)

SBS_MAIN_TARGET := $(SBS_ARTIFACT)
SBS_CLEAN_TARGET := $(SBS_ARTIFACT)_clean

endif # None empty target
######################### Binary build end #########################

ifneq ($(MODULE_SUB_MODULES),)
$(MODULE_SUB_MODULES):
	@$(MAKE) -C $@

SBS_CLEAN_SUFFIX := __clean
SBS_SUBMODULES_CLEAN := $(addsuffix $(SBS_CLEAN_SUFFIX),$(MODULE_SUB_MODULES))
$(SBS_SUBMODULES_CLEAN):
	@$(MAKE) -C $(@:$(SBS_CLEAN_SUFFIX)=) clean
endif

# Set the default target to 'all'. Make just picks up the first non empty
# target (or such). Here we make sure we control the make behavior.
.DEFAULT_GOAL := all
.PHONY: all clean $(SBS_CLEAN_TARGET)
.PHONY: $(MODULE_PRE_SUB_MODULES) $(MODULE_SUB_MODULES) $(MODULE_POST_SUB_MODULES) $(SBS_SUBMODULES_CLEAN)

SBS_BUILD_ORDER := $(strip $(MODULE_PRE_BUILD) $(MODULE_PRE_SUB_MODULES))
ifneq ($(SBS_ARTIFACT),)
SBS_BUILD_ORDER := $(strip $(SBS_BUILD_ORDER) $(strip $(SBS_MODULE_NAME)))
endif
SBS_BUILD_ORDER := $(strip $(SBS_BUILD_ORDER) $(strip $(MODULE_SUB_MODULES)))
SBS_BUILD_ORDER := $(strip $(SBS_BUILD_ORDER) $(strip $(MODULE_POST_BUILD) $(MODULE_POST_SUB_MODULES)))
ifneq ($(SBS_BUILD_ORDER),$(SBS_MODULE_NAME))
ifneq ($(SBS_BUILD_ORDER),)
SBS_ORDER_STR := " order=[$(SBS_BUILD_ORDER)]"
endif
endif


define SbsForEach
	for t in $(1); do $(2) $$t $(3) || exit $$? ; done
endef

all:
	@echo "Building '$(SBS_MODULE_NAME)'$(SBS_ORDER_STR)"
	@$(call SbsForEach,$(MODULE_PRE_BUILD),$(MAKE) -f $(SBS_BASE_MAKEFILE))
	@$(call SbsForEach,$(MODULE_PRE_SUB_MODULES),$(MAKE) -C)
	@$(MAKE) -f $(SBS_BASE_MAKEFILE) $(SBS_MAIN_TARGET) $(MODULE_SUB_MODULES)
	@$(call SbsForEach,$(MODULE_POST_SUB_MODULES),$(MAKE) -C)
	@$(call SbsForEach,$(MODULE_POST_BUILD),$(MAKE) -f $(SBS_BASE_MAKEFILE))

clean:
	@echo "Cleaning '$(SBS_MODULE_NAME)'$(SBS_ORDER_STR)"
	@$(call SbsForEach,$(MODULE_PRE_CLEAN),$(MAKE) -f $(SBS_BASE_MAKEFILE))
	@$(call SbsForEach,$(MODULE_PRE_SUB_MODULES),$(MAKE) -C, clean)
	@$(MAKE) -f $(SBS_BASE_MAKEFILE) $(SBS_CLEAN_TARGET) $(SBS_SUBMODULES_CLEAN)
	@$(call SbsForEach,$(MODULE_POST_SUB_MODULES),$(MAKE) -C, clean)
	@$(call SbsForEach,$(MODULE_POST_CLEAN),$(MAKE) -f $(SBS_BASE_MAKEFILE))

sbs_version:
	@echo SBS version $(SBS_VERSION)

define SbsDbgTitle
	TITLE="$(1)"; \
	COND_VALUE="$(2)"; \
	COND_VALUE="$${COND_VALUE#"$${COND_VALUE%%[![:space:]]*}"}"; \
	if [[ -z $${SBS_DBG_TERMS} && -n $${COND_VALUE} ]]; then \
		echo; \
		echo $${TITLE} ;\
		echo $${TITLE//?/=} ;\
	fi
endef

define SbsDbgVar
	NAME=$(1); \
	VALUE="$($(1))"; \
	if [[ -n $${VALUE} || $${SBS_FORCE_DBG} -eq 1 ]] && \
	   [[ -z $${SBS_DBG_TERMS} || $${NAME} == *"$${SBS_DBG_TERMS}"* ]]; then \
		if (( $${#VALUE} > $$(tput cols) -30 -5 )); then \
			read -ra elements <<< "$${VALUE}"; \
			printf "%-30s%s\n" $${NAME}: "$${elements[0]}"; \
			for (( i =1; i < $${#elements[@]}; i++ )); do \
				printf "%-30s%s\n" "" "$${elements[$$i]}"; \
			done; \
		else \
			printf "%-30s%s\n" $${NAME}: "$${VALUE}"; \
		fi; \
	fi
endef

sbs_dump_module_vars:
	@echo $(SBS_FORCE_DBG)
	@$(call SbsDbgTitle,Base Module Settings,Always)
	@$(call SbsDbgVar,MODULE_NAME)
	@$(call SbsDbgVar,MODULE_SRCS)
	@$(call SbsDbgVar,MODULE_LANG)
	@$(call SbsDbgVar,MODULE_FLAV)
	@$(call SbsDbgVar,MODULE_CSUITE)
	@$(call SbsDbgVar,MODULE_C_SUFFIXES)
	@$(call SbsDbgVar,MODULE_CXX_SUFFIXES)
	@$(call SbsDbgVar,MODULE_USE_PTHREAD)
	@$(call SbsDbgVar,MODULE_CDEFS)
	@$(call SbsDbgVar,MODULE_CWARNS)
	@$(call SbsDbgVar,MODULE_INCLUDE_DIRS)
	@$(call SbsDbgVar,MODULE_PROJECT_INCLUDE_DIRS)
	@$(call SbsDbgVar,MODULE_DEP_FLAGS)
	@$(call SbsDbgVar,MODULE_CFLAGS)
	@$(call SbsDbgVar,MODULE_CFLAGS_OVERRIDE)
	@$(call SbsDbgVar,MODULE_LDFLAGS)
	@$(call SbsDbgVar,MODULE_LDFLAGS_OVERRIDE)
	@$(call SbsDbgVar,MODULE_LIBS)
	@$(call SbsDbgVar,MODULE_LIB_DIRS)
	@$(call SbsDbgVar,MODULE_PROJECT_LIB_DIRS)
	@$(call SbsDbgVar,MODULE_EXTERN_OBJS)
	@$(call SbsDbgVar,MODULE_LD)
	@$(call SbsDbgVar,MODULE_ARTIFACT_DIR)

sbs_dump_module_submodules:
	@$(call SbsDbgTitle,Submodules Settings,\
		$(MODULE_SUB_MODULES) $(MODULE_PRE_SUB_MODULES) $(MODULE_POST_SUB_MODULES))
	@$(call SbsDbgVar,MODULE_PRE_SUB_MODULES)
	@$(call SbsDbgVar,MODULE_SUB_MODULES)
	@$(call SbsDbgVar,MODULE_POST_SUB_MODULES)

sbs_dump_module_build_steps:
	@$(call SbsDbgTitle,Build Steps,\
		$(MODULE_PRE_BUILD) $(MODULE_POST_BUILD) $(MODULE_PRE_CLEAN) $(MODULE_POST_CLEAN))
	@$(call SbsDbgVar,MODULE_PRE_BUILD)
	@$(call SbsDbgVar,MODULE_POST_BUILD)
	@$(call SbsDbgVar,MODULE_PRE_CLEAN)
	@$(call SbsDbgVar,MODULE_POST_CLEAN)

sbs_dump_module: sbs_dump_module_vars sbs_dump_module_submodules sbs_dump_module_build_steps

sbs_dump_internals:
	@$(call SbsDbgTitle,Base SBS Settings,Always)
	@$(call SbsDbgVar,SBS_MODULE_NAME)
	@$(call SbsDbgVar,SBS_MODULE_PATH)
	@$(call SbsDbgVar,SBS_PROJ_ROOT)
	@$(call SbsDbgVar,SBS_BASE_MAKEFILE)
	@$(call SbsDbgVar,SBS_VERSION)
	@$(call SbsDbgTitle,Build Settings,Always)
	@$(call SbsDbgVar,SBS_BIN_TYPE)
	@$(call SbsDbgVar,SBS_FLAV)
	@$(call SbsDbgVar,SBS_MAIN_TARGET)
	@$(call SbsDbgVar,SBS_CLEAN_TARGET)
	@$(call SbsDbgVar,SBS_SRCS)
	@$(call SbsDbgVar,SBS_CDEFS)
	@$(call SbsDbgVar,SBS_CWARNS)
	@$(call SbsDbgVar,SBS_INC_DIRS)
	@$(call SbsDbgVar,SBS_CFLAGS)
	@$(call SbsDbgVar,SBS_LD)
	@$(call SbsDbgVar,SBS_LIB_DIRS)
	@$(call SbsDbgVar,SBS_LIBS_FLAGS)
	@$(call SbsDbgVar,SBS_LDFLAGS)
	@$(call SbsDbgVar,SBS_OBJS_PATH)
	@$(call SbsDbgVar,SBS_OBJS)
	@$(call SbsDbgVar,SBS_OBJS_DEPS)
	@$(call SbsDbgVar,SBS_ARTIFACT)
	@$(call SbsDbgVar,SBS_ARTIFACT_DIR)
	@$(call SbsDbgVar,SBS_C_SUFFIXES)
	@$(call SbsDbgVar,SBS_CXX_SUFFIXES)
	@$(call SbsDbgVar,SBS_CSUITE)
	@$(call SbsDbgVar,SBS_CC)
	@$(call SbsDbgVar,SBS_CCPP)

sbs_dump_all: sbs_dump_module sbs_dump_internals

