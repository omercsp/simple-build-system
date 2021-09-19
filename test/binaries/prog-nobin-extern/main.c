#include "../nobin/nobin.h"
#include <sbstest-base.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
	pr_start();
	call_func(nobin_func0);
	call_func(nobin_func1);
	pr_end();
	return EXIT_SUCCESS;
}
