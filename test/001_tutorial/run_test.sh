#!/usr/bin/env bash
here=$(dirname "$(readlink -f ${BASH_SOURCE[0]})")

TEST_FLAV=${TEST_FLAV:-}
if [[ -z ${TEST_FLAV} ]]; then
	TEST_FLAV="dbg"
	[[ ${FULL_TEST} -eq 1 ]] && TEST_FLAV+=" rel"
fi

cd ${here} || exit 1

for flav in ${TEST_FLAV}; do
	echo "Testing '${flav}'"
	export MODULE_FLAV=${flav}
	make clean
	make
	obj/${flav}/tutorial
	echo
done

