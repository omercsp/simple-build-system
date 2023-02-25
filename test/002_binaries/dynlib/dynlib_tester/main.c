#include <sbstest-base.h>
#include <stdlib.h>

#include "../dynamic.h"

int main(int argc, char **argv)
{
	pr_start();
	call_func(dynlib_func0);
	pr_end();
	return EXIT_SUCCESS;
}
