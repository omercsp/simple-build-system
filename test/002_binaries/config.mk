MODULE_FLAV ?= dbg
MODULE_CWARNS := all error
MODULE_CDEFS := PROJECT_DEF=1
MODULE_PROJECT_INCLUDE_DIRS := test/002_binaries/include
MODULE_PROJECT_LIB_DIRS := test/002_binaries/lib/$(MODULE_FLAV)

MY_PROJECT_LIB_ARTIFACT_DIR := test/002_binaries/lib/$(MODULE_FLAV)