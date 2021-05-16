# Simple Build System
SBS is a light weight build system for C and C++ projects using gnu-make and GCC. It is intended for users who want a not-too-complicated build system that is easy to install and configure without the need to write complex makefiles or require any dependencies. SBS strives for simplicity and ease of use, making most of the build settings a matter of simple configuration, sparing the coder the need to write Makefile rules and for the most part, even understand how Makefiles work.

SBS allows easy configuration of many advanced (and not so advanced) build system aspects, all controlled by easy configuration:
- Compilation and linking settings
- Build flavor (Debug/Release)
- Automatic setup of source files dependencies
- Multi folders project support, with full control over build order
- And more

## Target systems
This system was built with and for Linux. It is the only platform SBS was verified for. However, it can probably be adapted to any system with gmake and gcc-like compiler.

## Dependencies
Other than Gnu-make and GCC, no additional packages or tools are required.

## Installation
Using SBS a GCC project consists of copying a single file - `module.inc.sh` - into the project root directory. From that point it's a matter of configuring the build by writing simple Makefiles . Since the entire build system is encapsulated in a single file without dependencies no installation process is required.

## Quick Start
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

Now it's time to tell SBS what to build and how. In order to so, add a Makefile to the same directory. No worries, it's going to be much smaller and much simpler than your usual Makefile. No rules are required, just very basic settings so SBS will know what to do. Only 3 lines are needed:

1. The name of the binary we want to build
2. List of objects to compile and link, in our example, a single object file.
3. Inclusion of the `module.inc.mk` file placed in our directory in the installation phase.

Here's how such a Makefile will look:
```makefile
MODULE_NAME := my_prog
MODULE_OBJS := main.o

include module.inc.mk
```
And that's it. You're done with setting up the build.

Now you can build the project, and run the created executable.

First, lets build the project by running make. It there are no compilation errors, the output should look something like this:
```makefile
project $ make
Building 'my_prog'
CC	main.o
LD	my_prog
project $
```

Now it's a good time to examine what happened in the project directory. Listing its content will reveal that a new directory named `obj` was created in the folder. All binary outputs are placed in that folder. A `my_prog` executable binary resides at `obj/dbg/my_prog`. The additional `dbg` folder indicates the build was done with debug flags. This is the default SBS behavior, and can be easily changed in the Makefile.
To run your program, invoke `obj/dbg/my_prog` from the project directory:

```
project $ obj/dbg/my_prog
Simple-Build-System hello world!
project $
```

And that concludes the very basic usage of the build system.
Browse the SBS repository for more advanced examples.

## Configuration basics
Configuration of SBS is done in the Makefiles themselves. Almost all SBS settings are defined using a gmake `<SETTING> := <VALUE>` syntax, so it is better to think of SBS Makefiles as configuration files rather than traditional Makefiles.

There are quite a few settings, allowing the user to control many aspects of the build. Guidelines and the more common tasks and settings are covered below. For a full list of possible settings and their documentation, see the `Makefile.skel`.

Each SBS Makefile must source (via `include` directive) the `module.inc.mk` file. It's location is up to the user to decide, but a reasonable place to put it is in the project root directory. A minimal SBS Makefile will look like this:

```makefile
include module.inc.mk
```

However, such a Makefile will do absolutely nothing. A somewhat more advanced SBS Makefile might look like this:

````makefile
include ../config.mk

MODULE_NAME := dynamic
MODULE_BIN_TYPE := shared
MODULE_LANG := c
MODULE_OBJS := dynamic.o
MODULE_CDEFS += DYNLIB_DEF=10
MODULE_POST_SUB_MODULES := dynlib_tester
MODULE_VERBOSE := 1
MODULE_ARTIFACT_DIR := $(MY_PROJECT_LIB_ARTIFACT_DIR)
MODULE_ARTIFACT_DIR_REL := 1

include ../module.inc.mk
````

Most of these settings are optional, and used for specific needs. For example, in the Makefile above example, the line `MODULE_CDEFS += DYNLIB_DEF=10` adds a pre-processor definition of `DYNLIB_DEF=10` to the build through a `-DDYNLIB_DEF=10` gcc flag. The `MODULE_POST_SUB_MODULES := dynlib_tester` line defines that once this Makefile (module) is built, a `make -C dynlib_tester` is invoked.

 All the possible settings and their meanings are described in the SBS repository`Makefile.skel` file. Some of the more important settings are described in this readme and its FAQ.

## Modules
In SBS terms, a module is a group of source files built by the same Makefile and linked to a binary. At it's simple and most common form, a module source files reside in a single folder. SBS supports creation of executable, static libraries and dynamic libraries as well as modules that only compile object files without linking them. (see `MODULE_BIN_TYPE` setting).

### Name

The module's name setting serves as the base name for the module linked output name (see type for more details). It also sets as the name SBS uses to output to the console about the build. If no name is set, SBS will use the directory base-name for a module name. So a nameless module that reside in `/dir0/dir1/dir2` will have the name `dir2`.  (see `MODULE_NAME` setting)

### Type

A module type defines the artifact type the module will produce. SBS module supports 4 kind of types: executables, dynamic libraries, static libraries and none, which compile all the objects in the module, but will not link them. Default type is executable (See `MODULE_TYPE` setting).

### Flavor

In SBS terms, a flavor is a predefined set of compilation settings to apply when building a module. SBS supports 3 flavors, one for debug, one for release, and an empty flavor. Debug and release flavors modify some compilation flags accordingly. (See `MODULE_FLAV` setting).

### Artifacts

As one can assume, there are 2 types of artifacts for a module's build: object files and a binary artifact. By default, all output files reside in `<MODULE_PATH>/obj/<FLAVOR>` , where flavor is determined by `MODULE_FLAVOR`.  The artifact location can be set to any location (See `MODULE_ARTIFACT_DIR` setting).

### Header dependencies

By default, SBS adds compilation flags for header files dependencies generation ('.d', files) for better make behavior on headers modification.  This behavior can be turned off. For more details about headers dependencies generation, consult GCC's documentation. (See `MODULE_NO_DEP_FLAGS` setting).

### Language

SBS supports C and C++ as valid module language. Unless explicitly set, SBS assumes C as the module's language. Module language affects two build characteristics:

1. Source file suffixes - When set to C,  'c' suffix is searched as source files. When set to C++, 'cpp' 'cxx' and 'cc' suffixes are searched. These values can be modified with `MODULE_C_SUFFIXES` and `MODULE_CXX_SUFFIXES` settings
2. The module linker - gcc for C modules and g++ for C++ modules.

(See `MODULE_LANG` setting).

#### Mixing C and C++ in the same module

SBS supports mixing both languages in the same module see the `Makefile.skel` for more details (See `MODULE_LANG` setting).

## Sub modules

Each module may define sub-modules that refer to directories to build by invoking `make -C` commands before, during or after the module is built - SBS a provides easy settings to define which and when sub modules are to be built.  Each sub module might be a SBS module, or any other directory with a valid Makefile in it.

A SBS module might serve as a *pseudo* module, with an empty object list but with sub modules defined.

Sub-modules settings allow creating of complex project hierarchies, with complete control over build order. (See `MODULE_SUB_MODULES`, `MODULE_PRE_SUB_MODULES` and `MODULE_PRE_POS_MODULES` settings).

## FAQ

### How to add an include directory?

With `MODULE_INCLUDE_DIRS`. Each entry `<DIR>` in the setting yields a `-I<DIR>` gcc flag. So a setting of

```makefile
MODULE_INCLUDE_DIRS := some_dir/include other_dir/inclue
```

will yield a `-Isome_dir/include -Iother_dir/inclue` in the module's object compile command.

### How to add a preprocessor definition?
With `MODULE_CDEFS `. Each entry `<DEF>` in the list yields a `-D<DEF>` gcc flag. So a setting of

```makefile
MODULE_CDEFS := _GNU_SOURCE USE_LOG=0
```

will yield a `-D_GNU_SOURCE -DUSE_LOG=0` in the module's object compile command.

### How to add a compiler warning setting?

With `MODULE_WARNS `. Each entry `<WARN>` in the list yields a `-W<WARN>` gcc flag. So a setting of

```makefile
MODULE_WARNS := no-import format
```

will yield a `-Wno-import -Wformat` in the module's object compile command. See GCC's documentation for possible warning settings.

### How to add a preprocessor definition?
With `MODULE_CDEFS `. Each entry `<DEF>` in the list yields a `-D<DEF>` gcc flag. So a setting of

```makefile
MODULE_CDEFS := _GNU_SORUCE USE_LOG=0
```

will yield a `-D_GNU_SORUCE -DUSE_LOG=0` in the module's object compile command.

### How to add a library to search when linking?

With `MODULE_LIB_DIRS`.  Each directory `<DIR>` in the list yields `-L<DIR>` gcc (linker) flag. So a setting of

```makefile
MODULE_LIB_DIRS := /opt/external_project0 /opt/external_project1
```

will yield a `-L/opt/external_project0 -L/opt/external_project1` flags in the link command.

### How to add a directory to the libraries search path?

Libraries to link with the module's artifact can be added using `MODULE_LIBS`. Each library `<LIB>` in the list yields a `-l<LIB>` gcc (linker) flag. So a setting of

```makefile
MODULE_INCLUDE_DIRS := m uuid
```

will yield a `-lm -luuid` flags in the link command.

### How to create a static or dynamic library?

A module artifact type is defined its `MODULE_BIN_TYPE` setting. Setting it to `static` or `shared` will create static or dynamic libraries respectively. The module's artifact name will be `lib<MODULE_NAME>.a` for static libraries and `lib<MODULE_NAME>.so` for dynamic libraries.

- Dynamic library setting implies `-fPIC` compilation flag and `-shared` link flag.
- Static libraries setting implies usage of `ar` for the linking tool instead of gcc/g++.

### How to to create a module that only compile object but doesn't link a target?

By setting `MODULE_BIN_TYPE`to `none`

```makefile
MODULE_BIN_TYPE := none
```

### How to change the module language from C to C++?

By setting `MODULE_LANG` to`cpp`

```makefile
MODULE_LANG := cpp
```

### How to set a different file suffix for source file?

By setting `MODULE_C_SUFFIXES` and `MODULE_CXX_SUFFIXES` for C and C++ respectively. For example, to set suffixes for a C++ module (assuming`MODULE_LANG` was set to `cpp` to set the module language to C++) ,with suffixes of `CPP`,  use the following setting:

```makefile
MODULE_CXX_SUFFIXES := CPP
```

### How to add other compilation and linking flags?

By setting `MODULE_CFLAGS` and `MODULE_LDFLAGS`.  These will add their content 'as is' to the compile and link steps.

### How to show the full compilation and linking commands?

By setting `MODULE_VERBOSE` to `1`

```makefile
MODULE_VERBOSE := 1
```

### How to change the artifact output location?

By setting `MODULE_ARTIFACT_DIR` to the desired output directory.

### How to add pre build and post build actions?

By setting `MODULE_PRE_BUILD` and `MODULE_PRE_BUILD`. These settings should refer to valid Make targets. It is up to the Makefile writer to make sure these target exist in the makefile, and unlike the reset of the makefile will require to write Makefile rules. For example to add a small pre-build target that displays a message to the screen at the beginning of each build the following setting can be used:

```makefile
MODULE_PRE_BUILD := display_message

display_message:
	@echo "This is displayed at the beginning of the build"
```

### How to control the order of sub-modules in parallel builds?

To set the order of plain sub modules (defined by `MODULE_SUB_MODULES`), dependencies between the sub modules should be explicitly set. For example if the following sub modules are defined `sm0 sm1 sm2` but we want to guarantee that `sm1` is build before `sm0` a dependency rule is due:

````makefile
MODULE_SUB_MODULES := sm0 sm1 sm2

sm0: sm1
````

Pre and post sub modules are built in the order they are specified one by one.

### How to set find and include the `module.inc.mk` file from a all SBS modules Makefiles?
SBS can't determine the location of the `module.inc.mk` relatively to the current module location. It is to the user to set,  and the `module.inc.mk` inclusion from each SBS Makefile of can be different.

Some solutions are available, however, using external tools. For example, with git, it is a good idea to place the `module.inc.mk` file relative to the `.git` directory (the same directory is the obvious choice), and use git to determine this location, so the following snippet can be used throughout all the modules within a given project:

```makefile
TOP_LEVEL=$(shell git rev-parse --show-toplevel)
include $(TOP_LEVEL)/module.inc.mk
```

Other tools and environments might provide their own solutions.

### Is there an easy way to build a module with pthread support?

Yes. Set the `MODULE_USE_PTHREAD` to 1, and both compilation and link flags will be added the `-pthread` flag.

