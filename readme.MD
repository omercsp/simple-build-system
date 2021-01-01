# Simple Build System
SBS is a light weight gnu-make build system for GCC c/cpp projects. It is intended for whoever wants to get and use a not-too-complicated build system that is easy to install and configure without the need to write complex makefiles. SBS strives to allow easy to use control of most of the common gmake/GCC abilities while keeping the configuration of the build system simple, sparing the coder the need to write Makefile rules and, to some degree, worry of GCC and Makefile settings.

## Target systems
This system was built with and for Linux, and it is the only platform SBS was verified for. However, it can probably be adapted to any system with gmake and gcc-like compiler.

## Prerequisites
Other than GNU-Make and GCC, no additional packages and tools are required.

## Installation
Installation of SBS into a GCC project consists of copying a single file `module.inc.sh` into the project root directory. The reset of the files in the SBS repository are for unit testing and as examples of advanced SBS configuration.
See the Quick Start section for a short example.

## Quick Start
In a folder named `project`, create a file named `main.c`. `project` is our project root directory. Here's a small example for you to paste:
```
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
        printf("Simple-Build-System hello world!\n");
        return EXIT_SUCCESS;
}

```
Now it's time to tell SBS what we want to build and how. In order to so, we add our own Makefile to the same directory. No worries, it's going to be much smaller and much simpler than your usual Makefile. No rules are required, just very basic settings so SBS will know what to do. tell the system what you want to build. Only 2 mandatory lines are required:
1. List of objects to compile and link, in our example, a single object file.
2. Inclusion of the `module.inc.mk` file placed in our directory in the installation phase.

Here's how such a Makefile will look:
```
MODULE_OBJS := main.o

include module.inc.mk

```
And your done with the configuration.

Notice we haven't defined a name for out binary to be built. Unspecified, SBS will choose the name of the folder twe are currently building. In our case, this result is `project`. If you want a different name for the binary output, just add a `MODULE_NAME := my_project` to the Makefile. This must be done before the include statement. Replace `my_project` with whatever file name you desire.

Now you can build the project, and run the created executable.

First, lets build the project by running make. It there are no complication errors, this should look something like this:
```
project $ make
Building 'project'
CC main.o
LD my_prog
project $
```

Now it's a good time to examine what happened in the project directory. Listing it's content will reveal that a new directory named `obj` was created in the folder. All binary outputs, are placed in that folder. The `my_prog` executable resides at `obj/dbg/my_prog`. The additional `dbg` folder indicates the build was done with debug flags. This is the default SBS behavior, and can be easily changed in the Makefile, but don't concern yourself with these details for now.
To run your program, just invoke `obj/dbg/my_prog` from the project directory:
```
project $ obj/dbg/my_prog
Simple-Build-System hello world!
project $
```

And that concludes the very basic usage of the build system.
Browse the SBS repository for more advanced examples.

## Manual
Coming soon
