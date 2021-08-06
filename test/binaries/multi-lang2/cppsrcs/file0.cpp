#include "header.h"

#include <sbstest-base.h>
#include <iostream>

void cppfile_func0(void)
{
	call_func(cfile_func1);
}

void cppfile_func1(void)
{
	std::cout << "Final call" << std::endl;
}
