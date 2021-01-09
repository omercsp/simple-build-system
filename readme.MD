# Simple Build System
SBS is a light weight gnu-make build system for GCC c/cpp projects. It is intended for users who want a not-too-complicated build system that is easy to install and configure without the need to write complex makefiles or require any dependencies. SBS strives fir simplicity and ease of use, making most of of the changes in the build during the development process a matter of configuration, sparing the coder the need to write Makefile rules and for the most part, even understand how Makefiles work.

SBS allows easy configuration of many advanced (and not so advanced) build system aspects, all controlled by easy configuration
- Compilation and linking flags
- Build flavor (Debug/Release)
- Automatic setup of source files dependencies
- Multi folders project support, with full control over build order
- And more

## Target systems
This system was built with and for Linux, and it is the only platform SBS was verified for. However, it can probably be adapted to any system with gmake and gcc-like compiler.

## Dependencies
Other than Gnu-make and GCC, no additional packages or tools are required.

## Installation
Installation of SBS into a GCC project consists of copying a single file - `module.inc.sh` - into the project root directory. Rest of the files in the SBS repository are for unit testing and can be used as examples of advanced SBS configuration. Since the entire system is encapsulated in a single file without dependencies, SBS is extremely portable, and can be used in different machines or containers with basic installation.

## Quick Start
In a folder named `project`, create a file named `main.c`. Here's a small example for you to paste:
```
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
        printf("Simple-Build-System hello world!\n");
        return EXIT_SUCCESS;
}

```
Now it's time to tell SBS what to build and how. In order to so, add a Makefile to the same directory. No worries, it's going to be much smaller and much simpler than your usual Makefile. No rules are required, just very basic settings so SBS will know what to do. Only 3 lines are needed:

1. The name of the binary we want to build
2. List of objects to compile and link, in our example, a single object file.
3. Inclusion of the `module.inc.mk` file placed in our directory in the installation phase.

Here's how such a Makefile will look:
```
MODULE_NAME := my_prog
MODULE_OBJS := main.o

include module.inc.mk

```
And that's it. You're done with setting up the build.

Now you can build the project, and run the created executable.

First, lets build the project by running make. It there are no complication errors, this should look something like this:
```
project $ make
Building 'my_prog'
CC main.o
LD my_prog
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

## Manual
Coming soon
