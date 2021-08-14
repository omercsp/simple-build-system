#include <nobin.h>
#include <sbstest-base.h>
#include <stdlib.h>

#include <static.h>
#include <dynamic.h>

int main(int argc, char **argv)
{
	pr_start();
	call_func(dynlib_func0);
	call_func(staticlib_func0);
	call_func(staticlib_additional_func0);
	call_func(staticlib_additional_func0);
	call_func(nobin_func0);
	call_func(nobin_func1);
	pr_end();
	return EXIT_SUCCESS;
}
