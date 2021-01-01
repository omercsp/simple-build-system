#include <stdio.h>
#include <stdlib.h>

#include <math.h>

class MyClass {
public:
	MyClass(int v):
	x(v)
	{}

	const int val(void) const { return x; }
private:
	int x;

};

int main(int argc, char **argv)
{
	MyClass o(16);

	printf("log(16)=%d\n", (int) log(o.val()));
	return EXIT_SUCCESS;
}
