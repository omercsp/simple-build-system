#!/bin/bash
here=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

TEST_FLAV=${TEST_FLAV:-}
if [[ -z ${TEST_FLAV} ]]; then
	TEST_FLAV="dbg"
	[[ ${FULL_TEST} -eq 1 ]] && TEST_FLAV+=" rel"
fi

TEST_CSUITE=${TEST_CSUITE:-}
if [[ -z ${TEST_CSUITE} ]]; then
	TEST_CSUITE="gcc"
	[[ ${FULL_TEST} -eq 1 ]] && TEST_CSUITE+=" clang"
fi

cd ${here}


for csuite in ${TEST_CSUITE}; do
	for flav in ${TEST_FLAV}; do
		echo "Testing '${csuite}/${flav}'"
		echo "================="
		export MODULE_FLAV=${flav}
		export MODULE_CSUITE=${csuite}

		set -e
		echo "Cleaning binaries"
		echo "-----------------"
		make -j clean  | grep -E "^Cleaning" | sort
		echo

		echo "Building binaries"
		echo "-----------------"
		make -j | grep -E "^Building" | sort
		echo

		echo "Checking binaries output"
		echo "------------------------"

		export LD_LIBRARY_PATH=${here}/lib/${flav}
		prog/obj/${flav}/prog
		dynlib/dynlib_tester/obj/${flav}/dyn_tester
		prog-nobin/obj/${flav}/prog_nobin
		prog-nobin-extern/obj/${flav}/prog-nobin-extern

		export LD_LIBRARY_PATH=${here}/prog2/prog2_dynlib/obj/${flav}
		prog2/obj/${flav}/prog2
		multi-lang/obj/${flav}/multi-lang
		multi-lang2/obj/${flav}/multi-lang2
		prog-with-out-of-tree-src/obj/${flav}/prog-with-out-of-tree-src
	done
done
