#include <stdio.h>

#include "../static.h"

int staticlib_additional_func0(void)
{
	printf("function=%s\n", __func__);
	return 0;
}
