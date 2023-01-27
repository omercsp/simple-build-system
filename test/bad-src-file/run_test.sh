#!/usr/bin/env bash
here=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
prog=$(basename ${here})
flav=${MODULE_FLAV:-dbg}

cd ${here}
make clean
# Since this is goind to spout out a Make erorr, which might differ
# between versions, suppress it and make sure the build really failed
make 2>&1 | head -n 2
rc=${PIPESTATUS[0]}
if [[ ${rc} -eq 0 ]]; then
	echo "Build succeeded, while it shouldn't"
	exit ${rc}
else
	echo "Build failed, (expected)"
fi
