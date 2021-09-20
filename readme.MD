[![Sanity](https://github.com/omercsp/simple-build-system/actions/workflows/sanity.yml/badge.svg?branch=master)](https://github.com/omercsp/simple-build-system/actions/workflows/sanity.yml)

# Simple Build System
SBS is a light weight build system for C/C++ projects using gnu-make and the either gnu compilers (gcc/g++) or LLVM compilers (clang/clang++). It is intended for users who want an easy to install and configure build system without the need to write complex makefiles, doesn't require additional dependencies and doesn't add any steps to the build process. SBS strives for simplicity and ease of use, making most of the build settings a matter of simple configuration, sparing the coder the need to write Makefile rules and for the most part, even understand how Makefiles work.

Partial list of SBS features:
- Simple compilation and linking settings
- Build flavors (Debug/Release)
- Automatic setup of source files dependencies
- Multi folders project support, with full control over build order
- Source and build output separation.
- And more

## Target systems
This system was built with and for Linux. It is the only platform SBS was verified for. However, it can probably be adapted to any system with gmake and gcc-like compiler.

## Dependencies
Other than Gnu-make and GCC or Clang suite, no additional packages or tools are required. SBS does assume `bash` is available, in particular SBS tests are to be run.

## Installation
Using SBS requires copying a single file - `module.inc.sh` - into the project root directory. From that point it's a matter of configuring the build by writing simple Makefiles.

## Quick Start Example
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

Now it's time to tell SBS what to build and how. In order to so, add a `Makefile` to the same directory. No worries, it's going to be much smaller and much simpler than your usual Makefile. No rules are required, just very basic settings so SBS will know what to do. Only 3 lines are needed:

1. The name of the binary we want to build
2. List of source files to compile and link, in our example, a single source file - `main.c`.
3. Inclusion of the `module.inc.mk` file placed in our directory in the installation phase.

Here's how such a Makefile will look:
```makefile
MODULE_NAME := my_prog
MODULE_SRCS := main.c

include module.inc.mk
```
And that's it. We're done with setting up the build, and ready to build the project, and run the created executable (we could have gotten away without the 1st line, but it's probably more clear this way).

First, lets build the project by running make. It there are no compilation errors, the output should look something like this:
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

A new directory named `obj` was created in the folder. All binary outputs are placed in that folder. A `my_prog` executable binary resides at `obj/dbg/my_prog`. The additional `dbg` folder indicates the build was done with debug flavor. This is the default SBS behavior, and can be changed. The `*.d` files in the build output are dependency files, which forces source files compilations in case a header dependency has changes. Don't worry if you are unfamiliar with dependency files.

To run your program, invoke `obj/dbg/my_prog` from the project directory:

```
project $ obj/dbg/my_prog
Simple-Build-System hello world!
project $
```

And that concludes the very basic usage of the build system.
Browse the SBS repository for more advanced examples.

## Configuration basics
SBS configuration is done in the Makefiles themselves. For a basic to intermediate use of SBS, no Makefile rules are needed and almost all SBS settings are defined using a gmake `<SETTING> := <VALUE>` syntax, so it is better to think of SBS Makefiles as configuration files rather than traditional Makefiles.

There are quite a few settings, allowing the user to control many aspects of the build. Guidelines and the more common tasks and settings are covered below. **For a full list of possible settings and their documentation, see the `Makefile.skel` file**.

Each SBS Makefile must source (via `include` directive) the `module.inc.mk` file. Its location is up to the user to decide. A reasonable place to put it is in the project root directory.

A minimal SBS Makefile will look like this:

```makefile
include module.inc.mk
```

However, such a Makefile will do absolutely nothing. A somewhat more advanced SBS Makefile might look like this:

````makefile
include ../config.mk

MODULE_NAME := dynamic
MODULE_BIN_TYPE := shared
MODULE_SRCS := file1.c file2.c file3.c file4.c
MODULE_CDEFS += DYNLIB_DEF=10
MODULE_POST_SUB_MODULES := dynlib_tester
MODULE_VERBOSE := 1
MODULE_ARTIFACT_DIR := $(MY_PROJECT_LIB_ARTIFACT_DIR)
MODULE_ARTIFACT_DIR_REL := 1

include ../module.inc.mk
````

Most of these settings are optional, and used for specific needs. In the Makefile above example, the line `MODULE_CDEFS += DYNLIB_DEF=10` adds a pre-processor definition of `DYNLIB_DEF=10` to the build through a `-DDYNLIB_DEF=10` flag. The `MODULE_POST_SUB_MODULES := dynlib_tester` line defines that once this Makefile (module) is built, a `make -C dynlib_tester` is invoked.

## Modules and artifacts
In SBS terms, a module is a group of source files built by the same Makefile and (possibly) linked to a single binary referred to as an artifact. At its most simple and common form, a module contains source files residing in a single folder with a SBS Makefile. More complicated setups can place source files in multiple folders.
#
### Name
The module's name setting serves as the base name for the module linked output name. It also sets the name SBS uses to output about the build. If no name is set, SBS will use the directory base-name as the module name. So a nameless module that reside in `/dir0/dir1/dir2` will have the name `dir2` (see `MODULE_NAME` setting).

### Type
A module type defines the artifact type build will produce. SBS module supports 4 kind of types: executables, dynamic libraries, static libraries and none. A `none` build type will compile all source files in the source list, but will not link them into an artifact. Default type is executable (See `MODULE_BIN_TYPE` setting).

### Source files
Source files for a module are defined with the `MODULE_SRCS` settings. It's a space separated list of files to be compiled. All source files must have a valid C or C++ suffix (e.g. `c`, `C`, `cpp`, `cxx`, etc.). See the [language](#language) section for more details about source files suffixes.

Source files can reside anywhere, as long as they accesible. SBS treats diffrently source files inside or outside the module's directory. Both types of files correspondig object files will reside inside the module's `obj` direcotry, so a source file can be compiled multiple times in different modules, possibly with different compilation flags, and differet objects will be created for them on each module.

#### White space in source names and paths
Due to gnu-Make limitations, SBS doesn't support source file with names or paths that contain white spaces.

### Flavor
In SBS terms, a flavor is a predefined set of compilation settings to apply when building a module. SBS supports 3 flavors, one for debug, one for release, and an empty flavor. Debug and release flavors modify some compilation flags accordingly. (See `MODULE_FLAV` setting).

### Build Output
A module build outputs up to 3 types of files

1. Object files
2. The target artifact (the executable or library)
3. Dependency file (See Header dependencies below)

By default, all output files reside in `<MODULE_PATH>/obj/<FLAVOR>`, where flavor is determined by `MODULE_FLAV`. The artifact location can be set to any location by setting `MODULE_ARTIFACT_DIR`.

### Header dependencies
By default, SBS adds compilation flags for header files dependencies generation (`.d`, files) for better build behavior on headers modification. This behavior can be turned off by setting `MODULE_NO_DEP_FLAGS` value to `1`. For more details about headers dependencies generation, consult the compiler's documentation.

### Language
SBS supports C and C++ as valid module languages, and tries to compile each source according to its suffix:

1. Default C suffixes are `c` and  `C`. Modifiable via the `MODULE_C_SUFFIXES` setting.
2. Default C++ suffixes are `cpp`, `cxx`, `cc`, `CC`, `CXX` and `CPP`. Modifiable via the `MODULE_CXX_SUFFIXES` setting.

Mixing of C and C++ in the same module is possible.

By default linkage tool is deduced by SBS according to the list of source files: If a C++ file is found among the list of source files, the C++ linker is used, otherwise the C linker is used. Most of the time, allowing SBS to choose the linker will generate the desired behavior, but SBS allows the user to explicitly choose a linker with the `MODULE_LD` setting.

### Compilers
SBS supports both GCC and Clang as compilers suite. By default, SBS uses GCC as it's compiler suite. To change this behavior, set the `MODULE_CSUITE` setting value to `clang`.

## Sub modules
Each module may define sub-modules that refer to directories to build. A sub module is any directory that has valid Makefile in it, so it doesn't have to be a SBS module by itself. A sub module can be built before, during or after the parent module itself is built. Under the hood, sub modules are built by  invoking `make -C`. SBS provides settings to define which and when sub modules are built. Sub-modules settings allow creating of complex project hierarchies, with complete control over build order. For example:

```makefile
MODULE_SRCS := main.cpp
MODULE_NAME := my_prog
MODULE_PRE_SUB_MODULES := pre_order
MODULE_SUB_MODULES := unordered0 unordered1
MODULE_POST_SUB_MODULES := post_order

include module.inc.mk
```

Running make over this Makefile is built as follows:

1. The `pre_order` sub module is built first
2. The current module is (`my_prog`) is built in parallel along with `unordered0` and `unordered1` sub modules
3. The `post_order` module is built afterwards

A SBS module might serve as a *pseudo* module, without any sources to compile but with sub modules defined.

 (See `MODULE_SUB_MODULES`, `MODULE_PRE_SUB_MODULES` and `MODULE_PRE_POS_MODULES` settings).

## FAQ
### How to add an include directory?
With `MODULE_INCLUDE_DIRS`. Each entry `<DIR>` in the setting yields a `-I<DIR>` flag. So a setting of

```makefile
MODULE_INCLUDE_DIRS := some_dir/include other_dir/inclue
```

will yield a `-Isome_dir/include -Iother_dir/inclue` in the module's objects compile command.

### How to add a preprocessor definition?
With `MODULE_CDEFS`. Each entry`<DEF>` in the list yields a `-D<DEF>` flag. So a setting of

```makefile
MODULE_CDEFS := _GNU_SOURCE USE_LOG=0
```

will yield a `-D_GNU_SOURCE -DUSE_LOG=0` in the module's objects compile command.

### How to add a compiler warning setting?
With `MODULE_CWARNS`. Each entry `<WARN>` in the list yields a `-W<WARN>`  flag. So a setting of

```makefile
MODULE_CWARNS := no-import format
```

will yield a `-Wno-import -Wformat` in the module's object compile command. See the compiler's documentation for possible warning settings.


will yield a `-D_GNU_SORUCE -DUSE_LOG=0` in the module's object compile command.

### How to add a library to search when linking?
With `MODULE_LIB_DIRS`.  Each directory `<DIR>` in the list yields `-L<DIR>` linker flag. So a setting of

```makefile
MODULE_LIB_DIRS := /opt/external_project0 /opt/external_project1
```

will yield a `-L/opt/external_project0 -L/opt/external_project1` flags in the link command.

### How to add a directory to the libraries search path?
Libraries to link with the module's artifact can be added using `MODULE_LIBS`. Each library `<LIB>` in the list yields a `-l<LIB>` linker flag. So a setting of

```makefile
MODULE_LIBS := m uuid
```

will yield a `-lm -luuid` flags in the link command.

### How to create a static or dynamic library?
A module artifact type is defined its `MODULE_BIN_TYPE` setting. Setting it to `static` or `shared` will create static or dynamic libraries respectively. The module's artifact name will be `lib<MODULE_NAME>.a` for static libraries and `lib<MODULE_NAME>.so` for dynamic libraries.

- Dynamic library setting implies `-fPIC` compilation flag and `-shared` link flag.
- Static libraries setting implies usage of `ar` for the linking step.

### Is it possible to create a module that only compile objects but doesn't link a target?
Yes, by setting `MODULE_BIN_TYPE` to `none`

```makefile
MODULE_BIN_TYPE := none
```

### How to set a different file suffix for source file?
By setting `MODULE_C_SUFFIXES` and `MODULE_CXX_SUFFIXES` for C and C++ respectively. For example, to set a `C++` suffix to be used in  the module use the following setting:

```makefile
MODULE_CXX_SUFFIXES := C++
```

Note, however, that this setting overrides the default C++ source suffixes, so changing this value should set all possible C++ source files in the module. The same logic applies to C files using `MODULE_C_SUFFIXES`.

### How to add other compilation and linking flags?
By setting `MODULE_CFLAGS` and `MODULE_LDFLAGS`. These will add their value 'as is' to the compile and link steps.

### How to show the full compilation and linking commands and output?
By setting `MODULE_VERBOSE` to `1`

```makefile
MODULE_VERBOSE := 1
```

### How to change the artifact output location?
By setting `MODULE_ARTIFACT_DIR` to the desired output directory.

### How to add pre build and post build actions?
By setting `MODULE_PRE_BUILD` and `MODULE_PRE_BUILD`. These settings should refer to valid Make targets. It is up to the Makefile writer to make sure these targets exist in the makefile, and unlike the rest of the makefile will require to write Makefile rules. For example to add a small pre-build target that displays a message to the screen at the beginning of each build the following setting can be used:

```makefile
MODULE_PRE_BUILD := display_message

display_message:
	@echo "This is displayed at the beginning of the build"
```

### How to control the order of sub-modules in parallel builds?
To set the order of plain sub modules (defined by `MODULE_SUB_MODULES`), dependencies between the sub modules should be explicitly set. For example, if sub modules `sm0 sm1 sm2` are defined but `sm1` must be built before `sm0`,  a dependency rule is due:

````makefile
MODULE_SUB_MODULES := sm0 sm1 sm2

sm0: sm1
````

Pre and post sub modules are built in the order they are specified one by one.

### How to include the `module.inc.mk` file from a all SBS modules Makefiles?
SBS can't determine the location of the `module.inc.mk` relatively to the current module location. It is for the user to set,  and the `module.inc.mk` inclusion path from each SBS Makefile of can be different.

Some solutions are available, however, using external tools. For example, with git, it is a good idea to place the `module.inc.mk` next to the `.git` directory, and use git to determine this location, so the following snippet can be used throughout all the modules within a given project:

```makefile
TOP_LEVEL=$(shell git rev-parse --show-toplevel)
include $(TOP_LEVEL)/module.inc.mk
```

Other tools and environments might provide their own solutions.

### Is there an easy way to build a module with pthread support?
Yes. Set the `MODULE_USE_PTHREAD` to 1, and both compilation and link flags will be added the `-pthread` flag.

