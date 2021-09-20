#!/bin/bash
here=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
flav=${MODULE_FLAV:-dbg}

cd ${here}

set -e
echo "Cleaning binaries"
echo "-----------------"
make -j clean  | grep -E "^Cleaning"
echo

echo "Building binaries"
echo "-----------------"
make -j | grep -E "^Building"
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

