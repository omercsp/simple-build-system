#ifndef __SBSTEST_BASE_H__
#define __SBSTEST_BASE_H__

#ifdef __cplusplus
#include <cstdio>
#else
#include <stdio.h>
#endif
#include <libgen.h>


#define pr_info(fmt, a...) printf("sbs-test [%s:%d]: " fmt, __func__, __LINE__, ##a)
#define pr_start() pr_info("Starting %s\n", basename(argv[0]))
#define pr_end() pr_info("Ending %s\n\n", basename(argv[0]))

#define call_func(func, args...)		\
do {						\
	pr_info("Calling %s\n", #func);		\
	func(args);				\
} while(0)

#endif /* __SBSTEST_BASE_H__ */
