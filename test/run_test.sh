#!/bin/bash
SCRIPT_PATH=$(readlink -f ${BASH_SOURCE[0]})
SBS_TEST_DIR=$(dirname ${SCRIPT_PATH})
SBS_DIR=${SBS_TEST_DIR}/..
SBS_MODULE_INC_MK_FNAME=module.inc.mk
SBS_MODULE_INC_FILE=${SBS_DIR}/${SBS_MODULE_INC_MK_FNAME}

_setup_module_inc_mk()
{
	local dir=${1}
	local file=${dir}/${SBS_MODULE_INC_MK_FNAME}

	if [[ -z ${dir} ]]; then
		echo "Missing direcotry argument"
		return 1
	fi

	if [[ ! -d ${dir} ]]; then
		echo "Directory argument '${dir}' isn't a directory"
		return 1
	fi
	[[ ${file} -ef ${SBS_MODULE_INC_FILE} ]] && return
	rm -f ${file}
	# Using hard links so when developing, there's no confusion
	ln ${SBS_MODULE_INC_FILE} ${file}
}

outfile=$(mktemp)
if [[ -n $* ]]; then
	test_dirs=($*)
else
	test_dirs=("binaries" "order")
fi
for d in ${test_dirs[@]}; do
	test_dir=${SBS_TEST_DIR}/${d}
	echo "Running test defined at '${d}'"
	_setup_module_inc_mk ${test_dir}
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
