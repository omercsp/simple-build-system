#include <sbstest-base.h>
#include <out-of-tree-src.h>
#include <stdlib.h>

int internal_func(void)
{
	__pr_info("\n");
	return 0;
}

int main(int argc, char **argv)
{
	pr_start();
	call_func(out_of_tree_func);
	call_func(internal_func);
	pr_end();
	return EXIT_SUCCESS;
}
