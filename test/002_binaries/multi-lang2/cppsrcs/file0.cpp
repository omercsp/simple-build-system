#include "header.h"

#include <sbstest-base.h>
#include <iostream>

void cppfile_func0(void)
{
	call_func(cfile_func1);
}

void cppfile_func1(void)
{
	// Use std::string to force *something* that is C++ specific, or else
	// libstdc++ will not be used.
	std::string cppMessage = "Final call";
	pr_info("%s\n", cppMessage.c_str());
}
