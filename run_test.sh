#!/bin/bash
SCRIPT_PATH=$(readlink -f ${BASH_SOURCE[0]})
SBS_TEST_DIR=$(dirname ${SCRIPT_PATH})/test

if [[ -n $* ]]; then
	test_dirs=($*)
else
	test_dirs=("tutorial" "binaries" "order")
fi

for flav in dbg rel; do
	outfile=$(mktemp)
	for d in ${test_dirs[@]}; do
		test_dir=${SBS_TEST_DIR}/${d}
		export MODULE_FLAV=${flav}
		echo "Running test at '${d}' (${flav})"
		if [[ ${SBS_TEST_VERBOSE} -eq 1 ]]; then
			${test_dir}/run_test.sh | tee ${outfile}
			ret=$?
		else
			${test_dir}/run_test.sh &> ${outfile}
			ret=$?
		fi
		if [[ ${ret} -ne 0 ]]; then
			echo "error running test at '${d}'"
			echo "----------------------------"
			cat ${outfile}
			echo "----------------------------"
			exit 1
		fi

		diff -u ${test_dir}/expected_output.txt ${outfile} || exit 1
		[[ ${SBS_TEST_VERBOSE} -eq 1 ]] && echo
	done

	rm ${outfile}
done
