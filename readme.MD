[![Sanity](https://github.com/omercsp/simple-build-system/actions/workflows/sanity.yml/badge.svg?branch=master)](https://github.com/omercsp/simple-build-system/actions/workflows/sanity.yml)

# Simple build system
SBS is a lightweight build system for C/C++ projects using GNU make and either GNU compilers (gcc/g++) or LLVM compilers (clang/clang++). It is intended for users who want an easy-to-install and easy-to-configure build system that doesn't require the user to write complex makefiles, has minimal dependencies and doesn't add steps to the build process. SBS strives for simplicity and ease of use, making most of the build settings a matter of simple configuration, sparing the coder the need to write Makefile rules and, for the most part, even to understand how Makefiles work.

Partial list of SBS features:
- Simple compilation and linking settings
- Build flavors (Debug/Release)
- Automatic setup of source files dependencies
- Multi-folder project support, with full control over build order
- Separation of source and build outputs

# Table of Contents
  - [Target systems](#target-systems)
  - [Dependencies](#dependencies)
  - [Installation](#installation)
  - [Quick start example](#quick-start-example)
  - [SBS basics](#sbs-basics)
    - [Modules](#modules)
    - [Build output and artifacts](#build-output-and-artifacts)
  - [Build configuration](#build-configuration)
    - [Name](#name)
    - [Binary artifact type](#binary-artifact-type)
      - [Executable](#executable)
      - [Shared library](#shared-library)
      - [Static library](#static-library)
      - [None](#none)
    - [Source files](#source-files)
      - [White space in source names and paths](#white-space-in-source-names-and-paths)
    - [Build flavors](#build-flavors)
      - [SBS internal flavors](#sbs-internal-flavors)
    - [Build output](#build-output)
    - [Compilers suite](#compilers-suite)
    - [Source file suffixes](#source-file-suffixes)
    - [Linker](#linker)
    - [Compilation settings](#compilation-settings)
      - [Headers search path (include directories)](#headers-search-path-include-directories)
      - [Preprocessor definitions](#preprocessor-definitions)
      - [Compiler warnings](#compiler-warnings)
      - [Pthread support](#pthread-support)
      - [Header dependencies](#header-dependencies)
      - [Overriding all compilation flags](#overriding-all-compilation-flags)
    - [Link settings](#link-settings)
      - [Linking with other libraries](#linking-with-other-libraries)
      - [Libraries search path](#libraries-search-path)
      - [Overriding all link flags](#overriding-all-link-flags)
  - [Sub-modules](#sub-modules)
    - [Sub-modules build order](#sub-modules-build-order)
    - [Example](#example)
  - [Invocation and Makefiles naming](#invocation-and-makefiles-naming)
  - [SBS debugging](#sbs-debugging)
    - [Variables dump](#variables-dump)
    - [Verbose output](#verbose-output)
  - [Misc](#misc)
    - [Pre-build and post-build steps](#pre-build-and-post-build-steps)
    - [Inclusion of `module.inc.mk` in a complex project structure](#inclusion-of-moduleincmk-in-a-complex-project-structure)


# Target systems
SBS was built specifically for Linux, which is the only platform on which SBS is verified for. However, although not officially supported, SBS is likely useable in any GNU based system.

# Dependencies
SBS assumes GNU Make and either the GCC or Clang suite are installed.It also relies on Bash but does not require any additional packages or tools.

# Installation
Using SBS requires copying a single file: `module.inc.mk`. From that point, it's a matter of configuring the build by writing simple Makefiles.

# Quick start example
In a folder named `project`, create a file named `main.c`. Here's a small example for you to paste:
```c
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
        printf("Simple-Build-System hello world!\n");
        return EXIT_SUCCESS;
}
```
Place the `module.inc.mk` file in the `project` folder.

Now it's time to tell SBS what to build and how. In order to do so, add a `Makefile` file to the same directory. Don't worry, it's going to be much smaller and much simpler than your usual Makefile. No rules are required, only basic settings to guide SBS. Only 3 lines are needed:

1. The name of the binary we want to build
2. List of source files to compile and link, in our example, a single source file - `main.c`
3. Inclusion of the module.inc.mk file placed in the directory during the installation phase.

Here's how such a Makefile will look:
```makefile
MODULE_NAME := my_prog
MODULE_SRCS := main.c

include module.inc.mk
```
That's it! The build setup is complete, and you are ready to build the project and run the executable.

First, let's build the project by running make. If there are no compilation errors, the output should look something like this:
```bash
project $ make
Building 'my_prog'
CC	main.c
LD	my_prog
project $
```

Now it's a good time to examine what happened in the project directory. Listing its content will reveal some changes:
```bash
project $ tree
.
├── main.c
├── Makefile
├── module.inc.mk
└── obj
    └── dbg
        ├── main.c.d
        ├── main.c.o
        └── my_prog

2 directories, 6 files
```

A new directory named `obj` was created in the project directory. All binary outputs are placed in that folder, including `my_prog`, the build executable. The additional `dbg` folder indicates a debug flavor was used. This is the default SBS behavior, and can be configured. The `*.d` files in the build output are dependency files, to force source files compilations in case a header dependency has changed. Don't worry if you are unfamiliar with dependency files.

To run your program, invoke `obj/dbg/my_prog` from the project directory:

```
project $ obj/dbg/my_prog
Simple-Build-System hello world!
project $
```

And that concludes the very basic usage of SBS.
Browse the SBS git repository test folder for more advanced examples.

# SBS basics
## Modules
In SBS terms, a module is a group of source files built by the same Makefile and (possibly) linked to a single binary referred to as an artifact. At its most simple and common form, a module contains source files residing in a single folder with a SBS Makefile. More complicated setups can place source files in multiple folders. Each module can have sub-modules to be build before, during and after the module build, as well as pre/post build steps.

## Build output and artifacts
A build produces object files, dependency files and linked binaries. Usually, the user is mainly concerned about the latter. SBS refers to binary outputs as `artifacts`.

# Build configuration
For a basic to intermediate use of SBS, no Makefile rules are needed and almost all SBS settings are defined using a GNU make `<SETTING> := <VALUE>` syntax, so it is better to think of SBS Makefiles as configuration files rather than traditional Makefiles.

There are quite a few settings, allowing the user to control many aspects of the build. Guidelines and most common configuration settings are covered below. **For a full list of possible settings and their documentation, see the [Makefile.skel](Makefile.skel) file**.

Following the module's settings, the Makefile must include (using `include`) the `module.inc.mk` file. It is important the inclusion directive is *after* the modules' settings.

A minimal SBS Makefile will look like this:

```makefile
include module.inc.mk
```

Though such a Makefile will do absolutely nothing.
A somewhat more advanced SBS Makefile might look like this:

````makefile
include ../config.mk

MODULE_NAME := mylibrary
MODULE_BIN_TYPE := shared
MODULE_SRCS := file1.c file2.c file3.c file4.c
MODULE_CDEFS += MY_DEF=10
MODULE_POST_SUB_MODULES := mylibrary_tester
MODULE_VERBOSE := 1
MODULE_ARTIFACT_DIR := /path/to/another/folder

include ../module.inc.mk
````

Most of these settings are optional and used for specific needs. In the Makefile above example, the line `MODULE_CDEFS += MY_DEF=10` adds a pre-processor definition of `MY_DEF=10` to the build through a `-DMY_DEF=10` flag. The `MODULE_POST_SUB_MODULES := dynlib_tester` line defines that once this Makefile (module) is built, a `make -C dynlib_tester` is invoked.

Internally, SBS defines variables and make targets prefixed with `sbs` and `SBS`. When writing SBS makefiles, these prefixes should be avoided, as they might get overridden.

SBS defines many variables upon the inclusion of `module.inc.mk`, all can be used *after* the include directive. For example, `SBS_OBJS` lists all the module's object files. There are many such variables, which might be useful in some cases. To see all the internal variables, use `make sbs_dump_internals`. See the [debugging](#sbs-debugging) section for more details.

---
**NOTE**

Some configuration settings details might look intimidating for the less experienced users. Yet for most of the configuration tasks, just getting them to work should be easy enough, even without understanding exactly what happens under the hood, so don't fret.

---

## Name
The module's name serves as the base name for the module linked output name. It is configured with the `MODULE_NAME` setting. The module's name is used for output. With no name set, SBS uses the directory base-name as the module name. So a nameless module that reside in `/dir0/dir1/dir2` will have the name `dir2`.

## Binary artifact type
A module type defines the artifact type the build produces. SBS module supports 4 kinds of types: executables, dynamic libraries, static libraries and none. The build type is controlled with `MODULE_BIN_TYPE`.

### Executable
For an `exec` `MODULE_BIN_TYPE` value, SBS builds an executable. This is the default value if `MODULE_BIN_TYPE` is not set. `exec` binary type doesn't modify any build flags.

### Shared library
For a `shared` `MODULE_BIN_TYPE` value, SBS builds a shared library, where:
- Artifact file name is set to `lib<MODULE_NAME>.so`
- Compilation flags are appended with `-fPIC`
- Link flags are appended with `-shared`

Refer to the selected build suite documentation for further details.

### Static library
For a `static` `MODULE_BIN_TYPE` value, SBS builds a static library, where:
- Artifact file name is set to `lib<MODULE_NAME>.a`
- Link command is `ar` based - `ar -rsc`.

Refer to `ar` documentation for further details.

### None
For a `none` `MODULE_BIN_TYPE` value, SBS doesn't build any artifact. It compiles all the source files in the `MODULE_SRCS` list, but does not link them. This module type setting doesn't affect any build flags.

## Source files
A module's source files are defined with `MODULE_SRCS`. It's a space separated list of files to be compiled. All source files must have a valid C or C++ suffix (e.g. `c`, `C`, `cpp`, `cxx`, etc.). See the [source file suffixes](#source-file-suffixes) section for more details about source files suffixes.

Source files can reside anywhere. Their corresponding object files are always created inside the module's own `obj` directory, so a source file can be compiled multiple times by different modules, possibly with different compilation flags, and different objects will be created on each module.

### White space in source names and paths
Due to GNU Make limitations, SBS doesn't support source files with names or paths that contain white spaces.

## Build flavors
Flavors are used to distinguish between different builds and their corresponding artifacts. Flavors are defined with `MODULE_FLAV` setting. With the exception of [SBS internal flavors](#sbs-internal-flavors), flavors only determine the module output directory. For a `MODULE_FLAV := myflav` entry, SBS will use `obj/myflav`, relative to the module directory, as the output directory. It is up to the user to put meaning into the flavor using different build options, and distinguishing it from other flavors.

All SBS modules must have a flavor. If no flavor is set, SBS defaults to the `dbg` flavor (see below).

---
**NOTE**

The idea of flavors, or 'build configurations', as they are called in other build systems, isn't unique to SBS and it is beyond the scope of this guide to explain how to manage them. Common approaches can be based on different project config files for each flavor controlled by renames or soft links, or a common config file branching internally according to an environment variable. To get things started, SBS default internal flavors should be sufficient for most cases.

---

### SBS internal flavors
SBS provides two internal flavors for debug and release. If the user sets the flavor type to either `dbg` or `rel` SBS will slightly modify the compilation flags with popular relevant settings:
- Debug (`dbg`) - `-g -O0 -DDEBUG=1 -D__DEBUG__=1`
- Release (`rel`) - `-O3`

If you are unfamiliar with these compile options and their meaning, refer the compiler's documentation.

To prevent SBS from adding any default flags to the build options (e.g., if you want full control over optimization levels), set `MODULE_USE_DEF_FLAV` to `0`.

## Build output
A module build outputs up to 3 types of files

1. Object files
2. The target artifact (the executable or library)
3. Dependency files (See [Header dependencies](#header-dependencies))

By default, all output files reside in `<MODULE_PATH>/obj/<FLAVOR>`, where flavor is determined by `MODULE_FLAV`. The artifact location can be set to any location by setting `MODULE_ARTIFACT_DIR`. `MODULE_ARTIFACT_DIR` is treated 'as is', and is relative to the current working directory. If it is an absolute path, the absolute path is the artifact directory.

However, if `MODULE_ARTIFACT_DIR_REL` is set to `1`, SBS will treat artifact directory set by `MODULE_ARTIFACT_DIR`, as a path relative to the project root directory (i.e. Where `module.inc.mk` resides in). This can be useful for settting a multi module project where binaries are to be placed in single known location, like a project level `lib` directory where other binaries can link with.

## Compilers suite
SBS supports GCC and Clang as compilers suites. By default, SBS uses GCC (`gcc`) as its compiler suite. To change this behavior, set the `MODULE_CSUITE` setting value to `clang`.

## Source file suffixes
SBS compiles a given source file as a C or C++ file according to its file extension:
1. Default C suffixes are `c` and `C`. Modifiable with the `MODULE_C_SUFFIXES` setting.
2. Default C++ suffixes are `cpp`, `cxx`, `cc`, `CC`, `CXX` and `CPP`. Modifiable with the `MODULE_CXX_SUFFIXES` setting.

Setting either `MODULE_C_SUFFIXES` or `MODULE_CXX_SUFFIXES` overrides the default C or C++ source suffixes. Ensure that all possible C or C++ source file suffixes for the module are included.

## Linker
By default, linkage tool is deduced by SBS according to the list of source files: If a C++ file is found among the list of source files, SBS will default to C++ linker, otherwise the C linker is used. Most of the time, allowing SBS to choose the linker will generate the desired behavior, but SBS allows the user to explicitly choose a linker with the `MODULE_LD` setting.

## Compilation settings
SBS provides a `MODULE_CFLAGS` setting to add any compilation flags. All compilation flags can be controlled with this setting alone. The content of `MODULE_CFLAGS` is appended to any of the module's object compilation command.

SBS also provides dedicated settings for the more common compilation configuration options - header search directories, pre-processor definition, compiler warnings and a few other. These are usually easier to write and maintain than putting all the compilation settings inside `MODULE_CFLAGS` and should generally be preferred over the general `MODULE_CFLAGS`, but it is up to the user to decide how to configure the build. See below for possible dedicated compilation settings.

### Headers search path (include directories)
Search path for headers can be appended to the module's compilation commands by setting `MODULE_INCLUDE_DIRS`. It's space separated lists of directories, where each entry `<DIR>` yields a `-I<DIR>` flag in the compilation command.

The following example yields a `-Isome_dir/include -Iother_dir/include` in the module's objects compile command:
```makefile
MODULE_INCLUDE_DIRS := some_dir/include other_dir/include
```
### Preprocessor definitions
Preprocessor definitions can be added to the module's compilation with the `MODULE_CDEFS` setting. It's space separated lists of definitions, where each entry `<DEF>` in the setting yields a `-D<DEF>` flag in the compilation command.

The following example yields a `-D_GNU_SOURCE -DUSE_LOG=0` in the module's objects compile command:
```makefile
MODULE_CDEFS := _GNU_SOURCE USE_LOG=0
```
### Compiler warnings
Compiler warnings are controlled with the `MODULE_CWARNS` setting. It's space separated lists of warnings, where each entry `<WARN>` in the setting yields a `-W<WARN>` flag in the compilation command. So a setting of

The following setting yields a `-Wno-import -Wformat` in the module's object compile command:
```makefile
MODULE_CWARNS := no-import format
```
### Pthread support
GCC and clang provide a specific pthread support using a `-pthread` flag on both compile and link commands. SBS provides a convenience wrapper around this setting with the `MODULE_USE_PTHREAD` setting. Setting it to 1, will add the `-pthread` to the compile and link commands.

### Header dependencies
By default, SBS adds compilation flags for header files dependencies generation (`.d`, files) for better build behavior on headers modification. Unchanged, compilation flags are appended with `-MMD -MP`. This behavior can be turned off by setting `MODULE_DEP_FLAGS` value to `0`.

For more details about headers dependencies generation, consult the compiler's documentation.

### Overriding all compilation flags
SBS provides a `MODULE_CFLAGS_OVERRIDE` setting to completely override all settings of the compilation, either defined by the user or appended by SBS itself. If you find yourself using this setting extensively, you are probably either misusing SBS or should look for a better suited build system.

## Link settings
As with compilation, SBS provides a `MODULE_LDFLAGS` setting to add any flag to the linker. The content of `MODULE_LDFLAGS` is appended to any of the module's link command.

SBS also provides a couple of link flags settings for the more common link configuration options - libraries to link against and library search directories. These are usually easier to write and maintain than putting all the link flags inside `MODULE_LDFLAGS`, and should generally be preferred over the general `MODULE_LDFLAGS`, but it is up to the user to decide how to configure the build. See below for possible dedicated link settings.

### Linking with other libraries
Libraries to link against can be set with `MODULE_LIBS`. It's space separated lists of libraries, where each entry `<LIB>` yields a `-l<LIB>` flag in the link command.

The following setting yields a `-lm -luuid` in the module's artifact link command:
```makefile
MODULE_LIBS := m uuid
```
### Libraries search path
Libraries search path can be set with `MODULE_LIB_DIRS`. It's space separated lists of directories, where each entry `<DIR>` yields a `-L<DIR>` flag in the link command.

The following setting yields a `-L/opt/external_project0 -L/opt/external_project1` in the module's artifact link command:

```makefile
MODULE_LIB_DIRS := /opt/external_project0 /opt/external_project1
```
### Overriding all link flags
A `MODULE_LDFLAGS_OVERRIDE` setting can be used to completely override all linker flags, either defined by the user or those appended by SBS itself.

# Sub-modules
Each module may define sub-modules. A sub-module is a directory with a valid Makefile in it. It doesn't have to be a SBS module by itself. A sub module can be built before, during or after the parent module. Sub-modules allow complex project folders and build hierarchies. SBS modules might serve as *pseudo* modules, with no sources to compile but with sub modules. Under the hood, sub modules are built by invoking `make -C`. SBS provides settings to define which and when sub modules are built.

`MODULE_SUB_MODULES` - List of folders to be build along the current module.
`MODULE_PRE_SUB_MODULES` - List of folders to be built before the current module.
`MODULE_POST_SUB_MODULES` - List of folders to be after before the current module.

## Sub-modules build order
Sub-modules defined by `MODULE_PRE_SUB_MODULES` are built first, followed by the current module. Next, sub-modules in `MODULE_SUB_MODULES` are built, and finally, those in `MODULE_POST_SUB_MODULES` are built.

When executing a parallel build (i.e. With `make -j`), the major difference is with the parent module and its sub modules defined in `MODULE_SUB_MODULES`, as they are all built in parallel. Pre and post sub-modules are still built one by one according to the order they are defined (Each sub-module is still built in parallel internally).

To control the order of sub-modules within `MODULE_SUB_MODULES`, dependencies rules between the sub modules should be explicitly set. For example, if sub modules `sm0 sm1 sm2` are defined but `sm1` must be built before `sm0`, a dependency rule is due:

````makefile
MODULE_SUB_MODULES := sm0 sm1 sm2

sm0: sm1
````

## Example
Given the following example:

```makefile
MODULE_SRCS := main.cpp
MODULE_NAME := my_prog
MODULE_PRE_SUB_MODULES := pre_order
MODULE_SUB_MODULES := unordered0 unordered1
MODULE_POST_SUB_MODULES := post_order

include module.inc.mk
```
- Running make without parallel build, will build modules in this order:
1. `pre_order`
2. `my_prog`
3. `unordered0`
4. `unordered0`
5. `post_order`

Running make over this Makefile with parallel build will build the current and regular sub-modules in parallel:
1. `pre_order`
2. `my_prog` (current module), `unordered0` and `unordered1` are built in parallel
3. `post_order`

# Invocation and Makefiles naming
As a general rule, SBS Makefiles should be simply named `Makefile`, where one Makefile exists in every module directory. Like other GNU-based systems, to run SBS the user should do either of the following:
1. Enter the module's directory and run `make`
2. Run `make -C <MODULE_DIR>`.

Occasionally, one might want to have explicit Makefile names in a given directory, where builds are invoked using `make -f <FILENAME>`. SBS offers some support for this type of build command. A SBS Makefile can be named whatever and executed with a `make -f` command, but there are a few notes to consider:
1. Sub-modules are always built using a default Makefile.
2. While true for Makefile in general, it's still worth mentioning that more than one Makefile in the same directory (i.e. `Makefile.A` and `Makefile.B`) are hard to maintain and should be carefully written so they won't overwrite one another output. It is usually best avoided.

# SBS debugging
In the rare and unheard of case of a buggy build, SBS provides a couple of debugging mechanics:
## Variables dump
SBS auto defines a special `sbs_dump_internals` target that shows SBS internal variables generated after the `module.inc.mk` inclusion. This can be used to get some sight into the build process internals.
All the variables shown by the `sbs_dump_internals` are available to use (if needed) *after* the inclusion of the `module.inc.mk` file.

SBS also auto defines few targets to summarize the input received from the user (i.e. Defined by the user using `MODULE_<SETTIMG>`):
1. `sbs_dump_module_vars` - Summary of the module's basic variables
2. `sbs_dump_module_submodules` - Summary of the module's sub-modules variables
3. `sbs_dump_module_build_steps` - Summary of the module's build steps (i.e. Pre and post build) variables.

These targets variants are helpful when working projects where modules makefiles are generated or include other makefiles (as often happens when managing flavors). In the simple case of a self contained module, the target will just echo the module's own variables.

By default, SBS only dumps non-empty variables. To show all variables regardless of there content, set `SBS_FORCE_DBG` to `1` on invoke. For example on `sbs_dump_module_vars`: `make SBS_FORCE_DBG=1 sbs_dump_module_vars`.
A target named `sbs_dump_module` combines dump of all module's dump target
A target named `sbs_dump_all` combines dump of all module's dump target and the SBS internal target.
## Verbose output
Setting `MODULE_VERBOSE` to `1` will generate the full build and link commands instead of the easier on the eyes `CC <FILE>` and `LD <FILE>` messages. After setting `MODULE_VERBOSE` to `1` in the quick start example, the output might look like this:
```bash
project $ make clean; make
Cleaning 'my_prog'
rm -f /home/user/project/obj/dbg/main.c.o /home/user/project/obj/dbg/main.c.d /home/user/project/obj/dbg/my_prog
Building 'my_prog'
gcc -MMD -MP -g -O0 -DDEBUG=1 -D__DEBUG__=1 -c /home/user/project/main.c -o /home/user/project/obj/dbg/main.c.o
gcc  -o /home/user/project/obj/dbg/my_prog /home/user/project/obj/dbg/main.c.o
```

# Misc
## Pre-build and post-build steps
SBS defines `MODULE_PRE_BUILD` and `MODULE_POST_BUILD` for actions to be taken before and after a module's build. These settings should refer to valid Make targets. Thus, it requires writing Makefile rules.

The following example adds a pre-build target that displays a message to the screen at the beginning of the build:

```makefile
MODULE_PRE_BUILD := display_message

display_message:
	@echo "This is displayed at the beginning of the module's build"
```

## Inclusion of `module.inc.mk` in a complex project structure
SBS cannot determine the location of the `module.inc.mk` file relative to the current module. The user must set this path, and it may differ for each SBS Makefile.

It's possible to mitigate this problem with external tools. For example, with git, it is a good idea to place the `module.inc.mk` next to the `.git` directory, and use git to determine this location, so the following snippet can be used throughout all the modules within a given project:

```makefile
PROJ_ROOT=$(shell git rev-parse --show-toplevel)
include $(PROJ_ROOT)/module.inc.mk
```
Other tools and environments might provide alternative solutions.
