#!/bin/bash
here=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
flav=${MODULE_FLAV:-dbg}
bad_makefile=Makefile.bad
good_makefile=Makefile.good

cd ${here}

_run_failed_test()
{
	local good_str=$1
	local bad_str=$2

	sed -e "s/${good_str}/${bad_str}/" ${good_makefile} > ${bad_makefile}

	# Remove the compile and link messages, they are not relevant for this
	# test and make reviewing harder
	make -f ${bad_makefile} 2> /dev/null | \
		sed -e "/^CC/d" -e "/^LD/d"
	rc=${PIPESTATUS[0]}

	if [[ ${rc} -eq 0 ]]; then
		echo "Build succeeded, while it shouldn't"
		exit ${rc}
	else
		echo "Build failed, (expected)"
	fi
	echo ${rc}
	echo
}

# First, lets check the original construct is valid

make -f Makefile.good clean
make -f Makefile.good | sed -e '/^CC/d' -e '/^LD/d'
obj/dbg/failures

echo
# Pre build
echo "Pre build failure - start"
_run_failed_test "prebuild0 prebuild1"  "bad_step prebuild0 prebuild1"

echo "Pre build failure - middle"
_run_failed_test "prebuild0 prebuild1"  "prebuild0 bad_step prebuild1"

echo "Pre build failure - end"
_run_failed_test "prebuild0 prebuild1"  "prebuild0 prebuild1 bad_step"

# Pre submodules
echo "Pre sub-modules failure - start"
_run_failed_test "ok0 ok1" "bad_submodule ok0 ok1"

echo "Pre sub-modules failure - middle"
_run_failed_test "ok0 ok1" "ok0 bad_submodule ok1"

echo "Pre sub-modules failure - end"
_run_failed_test "ok0 ok1" "ok0 ok1 bad_submodule"

# Bad current module
echo "Bad current module"
_run_failed_test "main.c" "main.c no_src.c"

# Sub-modules
echo "Sub-modules failure - start"
_run_failed_test "ok2 ok3" "bad_submodule ok2 ok3"

echo "Sub-modules failure - middle"
_run_failed_test "ok2 ok3" "ok2 bad_submodule ok3"

echo "Sub-modules failure - end"
_run_failed_test "ok2 ok3" "ok2 ok3 bad_submodule"

# Post submodules
echo "Post sub-modules failure - start"
_run_failed_test "ok4 ok5" "bad_submodule ok4 ok5"

echo "Post sub-modules failure - middle"
_run_failed_test "ok4 ok5" "ok4 bad_submodule ok5"

echo "Post sub-modules failure - end"
_run_failed_test "ok4 ok5" "ok4 ok5 bad_submodule"

# Post build
echo "Post build failure - start"
_run_failed_test "postbuild0 postbuild1"  "bad_step postbuild0 postbuild1"

echo "Post build failure - middle"
_run_failed_test "postbuild0 postbuild1"  "postbuild0 bad_step postbuild1"

echo "Post build failure - end"
_run_failed_test "postbuild0 postbuild1"  "postbuild0 postbuild1 bad_step"

rm ${bad_makefile}
