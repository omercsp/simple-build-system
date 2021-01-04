#include <stdio.h>

int prog2_dynlib_func0(void)
{
	printf("function=%s, PROJECT_DEF=%d\n", __func__, PROJECT_DEF);
	return 0;
}
