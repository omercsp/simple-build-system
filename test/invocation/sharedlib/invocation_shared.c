#include "invocation_shared.h"

#include <stdio.h>
#include <stdlib.h>

void submodule_func(int argc, char **argv)
{
	printf("SBS invoke style test:");
	for (int i = 1; i < argc; ++i)
		printf(" %s", argv[i]);
	printf("\n");
}
