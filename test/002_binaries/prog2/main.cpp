#include "prog2_dynlib/prog2_dynlib.h"
#include <sbstest-base.h>
#include <math.h>
#include <stdlib.h>

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
	pr_start();
	pr_info("log(16)=%d\n", (int) log(o.val()));
	call_func(prog2_dynlib_func0, 0);
	pr_end();
	return EXIT_SUCCESS;
}
