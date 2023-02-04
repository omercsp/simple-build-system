#include "nobin.h"

#include <sbstest-base.h>
#include <stdio.h>

int nobin_func1(void)
{
	pr_info("function=%s\n", __func__);
	return 0;
}

