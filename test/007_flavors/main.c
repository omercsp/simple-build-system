#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
	printf("flavor test\n");
#ifdef __DEBUG__
	printf("Has debug1 %d\n", __DEBUG__);
#else
	printf("Has no debug1\n" );
#endif
#ifdef DEBUG
	printf("Has debug2 %d\n", DEBUG);
#else
	printf("Has no debug2\n" );
#endif
	return EXIT_SUCCESS;
}
