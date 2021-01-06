#include <stdio.h>
#include <stdlib.h>

#include <static.h>
#include <dynamic.h>

int main(int argc, char **argv)
{
	dynlib_func0();
	staticlib_func0();
	staticlib_additional_func0();
	return EXIT_SUCCESS;
}
