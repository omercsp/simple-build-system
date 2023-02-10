#!/bin/bash
here=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
sharedlib_dir=${here}/sharedlib
sharedlib_dir_obj=${sharedlib_dir}/obj
flav=${MODULE_FLAV:-dbg}
prog=${here}/obj/${flav}/$(basename ${here})

export LD_LIBRARY_PATH=${here}/lib/${flav}

_run()
{
	local make="make --no-print-directory $1"
	local print_suffix=$2

	rm -rf ${here}/obj ${here}/lib
	${make} > /dev/null
	${prog} "Sanity ${print_suffix}"

	rm -rf ${here}/obj ${here}/lib
	${make} -C . > /dev/null
	${prog} "In project, but with -C ${print_suffix}"

	cd ${here}/..
	rm -rf ${here}/obj ${here}/lib
	${make} -C ${here}  > /dev/null
	${prog} "One directory out ${print_suffix}"

	cd ${here}/../..
	rm -rf ${here}/obj ${here}/lib
	${make} -C ${here} > /dev/null
	${prog} "Two directories out ${print_suffix}"


	cd ${here}/sharedlib
	rm -rf ${here}/obj ${here}/lib
	${make} -C ${here} > /dev/null
	${prog} "One directory in ${print_suffix}"
}

# Test 'make -C'
cd ${here}
cp Makefile.base Makefile
_run

# Test 'make -C'
cd ${here}
rm Makefile
_run "-f Makefile.base" "(using -f)"
