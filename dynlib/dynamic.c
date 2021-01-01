#include <stdio.h>

int dynlib_func0(void)
{
	printf("function=%s, DYNLIB_DEF=%d PROJECT_DEF=%d\n", __func__, DYNLIB_DEF, PROJECT_DEF);
	return 0;
}
