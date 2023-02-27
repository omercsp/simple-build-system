#!/bin/bash
set -e

here=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
makefile_base=Makefile.base
makefile=Makefile
DEFAULT="default"

_cleanp()
{
	rm -f ${here}/${makefile}
}
_test_flavor()
{
	local flav=$1
	local use_sbs_def=$2
	local prog=obj/${flav}/flavor

	echo "-----------------"
	echo "Flavor=${flav} use_sbs_def=${use_sbs_def}"
	sed -e "s/MODULE_FLAV :=/MODULE_FLAV := ${flav}/" ${makefile_base} > ${makefile}
	if [[ ${use_sbs_def} == ${DEFAULT} ]]; then
		sed -i -e '/MODULE_USE_DEF_FLAV :=/d' ${makefile}
	else
		sed -i -e "s/MODULE_USE_DEF_FLAV :=/MODULE_USE_DEF_FLAV :=${use_sbs_def}/" ${makefile}
	fi

	make -j
	${prog}

	[[ ${use_sbs_def} == ${DEFAULT} ]] && use_sbs_def=1
	[[ (${flav} != "dbg" && ${flav} != "rel") || ${use_sbs_def} -ne 1 ]] && return

	if file ${prog} | grep -q debug_info; then
		echo "Debug info exists"
	else
		echo "No debug info"
	fi
}

rm -rf ${here}/obj
cd ${here}
trap _cleanp EXIT

_test_flavor dbg ${DEFAULT}
_test_flavor dbg 1
_test_flavor dbg 0
_test_flavor rel ${DEFAULT}
_test_flavor rel 1
_test_flavor rel 0
_test_flavor newflav ${DEFAULT}
_test_flavor newflav 1
_test_flavor newflav 0

echo "-----------------"
echo "Testing illegal flavor (expecting failure)"
flav="one two"
sed -e "s/MODULE_FLAV :=/MODULE_FLAV := one two/" ${makefile_base} > ${makefile}
sed -i -e '/MODULE_USE_DEF_FLAV :=/d' ${makefile}
make -j 2>&1 | grep -q "Invalid flavor" # will fail due to set -e
if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
	echo "Illegal flavor make succeeded"
	exit 1
else
	echo "Make failed (expected)"
fi

echo "-----------------"
echo "Testing illegal flavor default setting usage (expecting failure)"
flav="dbg"
sed -e "s/MODULE_FLAV :=/MODULE_FLAV := ${flav}/" ${makefile_base} > ${makefile}
sed -i -e 's/MODULE_USE_DEF_FLAV :=/MODULE_USE_DEF_FLAV := 2/' ${makefile}
make -j 2>&1 | grep -q "Illegal default flavor options setting" # will fail due to set -e
if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
	echo "Illegal flavor make succeeded"
	exit 1
else
	echo "Make failed (expected)"
fi
