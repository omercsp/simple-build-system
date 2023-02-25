#!/bin/bash
here=$(dirname $(readlink -f ${BASH_SOURCE[0]}))

TEST_FLAV=${TEST_FLAV:-}
if [[ -z ${TEST_FLAV} ]]; then
	TEST_FLAV="dbg"
	[[ ${FULL_TEST} -eq 1 ]] && TEST_FLAV+=" rel"
fi

cd ${here}

for flav in ${TEST_FLAV}; do
	echo "Testing '${flav}'"
	export MODULE_FLAV=${flav}
	make -j clean
	make -j
	obj/${flav}/tutorial
	echo
done

