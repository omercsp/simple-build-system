#include <sbstest-base.h>

int dynlib_func0(void)
{
	pr_info("DYNLIB_DEF=%d PROJECT_DEF=%d\n", DYNLIB_DEF, PROJECT_DEF);
	return 0;
}
