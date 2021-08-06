#include "header.h"

#include <stdlib.h>
#include <sbstest-base.h>

int main(int argc, char **argv)
{
	pr_start();
	call_func(cfile_func0);
	pr_end();

	return EXIT_SUCCESS;
}
