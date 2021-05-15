#include "header.h"

#include <sbstest-base.h>
#include <iostream>

int main(int argc, char **argv)
{
	pr_start();
	call_func(cfile_func);
	pr_end();

	return EXIT_SUCCESS;
}
