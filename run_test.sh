#!/usr/bin/env bash
SCRIPT_PATH=$(readlink -f ${BASH_SOURCE[0]})
SBS_TEST_DIR=$(dirname ${SCRIPT_PATH})/test

# Use the folllowing environment variables to control the test script:
DIFF_TOOL=${DIFF_TOOL:-diff -u} # Set to the diff tool to use (default: diff -u)
EXIT_ON_FAILURE=${EXIT_ON_FAILURE:-1} # Set to 0 to not exit on failure
KEEP_OUTPUT=${KEEP_OUTPUT:-0} # Set to 1 to keep the output file
UPDATE_RESULTS=${UPDATE_RESULTS:-0} # Set to 1 to update the expected output
VIEW_ONLY=${VIEW_ONLY:-0} # Set to 1 to just run the test and view the output, no comparison

if [[ -z $* ]]; then
	test_dirs=$(find ${SBS_TEST_DIR} -maxdepth 1 -type d -not -path ${SBS_TEST_DIR} | sort)
else
	test_dirs=$*
fi

export FULL_TEST=1
for dir in ${test_dirs}; do
	if [[ ! -d ${dir} ]]; then
		echo "WARNING: Skipping non-directory '${dir}'"
		continue
	fi
	expected_output=${dir}/expected_output.txt
	outfile=${dir}/test_output.txt
	test_cmd=${dir}/run_test.sh
	if [[ ! -x ${test_cmd} ]]; then
		echo "Skipping non-executable test script '${test_cmd}'"
		continue
	fi
	echo "Running test at '$(basename ${dir})'"
	if [[ ${VIEW_ONLY} -eq 1 ]]; then
		${test_cmd}
	elif [[ ${SHOW_OUTPUT} -eq 1 ]]; then
		${test_cmd} 2>&1 | tee ${outfile}
	else
		${test_cmd} &> ${outfile}
	fi
	ret=$?
	if [[ ${ret} -ne 0 ]]; then
		echo "error running test at '${dir}'"
		echo "----------------------------"
		cat ${outfile}
		echo "----------------------------"
		exit 1
	fi
	if [[ ${VIEW_ONLY} -eq 1 ]]; then
		continue
	fi
	if [[ ${UPDATE_RESULTS} -eq 1 ]]; then
		mv ${outfile} ${expected_output}
		echo "Updated expected output at '${expected_output}'"
		continue
	fi

	if cmp --silent ${outfile} ${expected_output}; then
		[[ ${SBS_TEST_VERBOSE} -eq 1 ]] && echo "Test passed"
		rm ${outfile}
		continue
	fi

	[[ -n ${DIFF_TOOL} ]] && ${DIFF_TOOL} ${dir}/expected_output.txt ${outfile}
	[[ ${KEEP_OUTPUT} -ne 1 ]] && rm ${outfile}
	[[ ${EXIT_ON_FAILURE} -eq 1 ]] && exit 1
done

