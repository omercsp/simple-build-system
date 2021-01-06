#!/bin/bash
here=$(dirname $(readlink -f ${BASH_SOURCE[0]}))

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
export LD_LIBRARY_PATH=${here}/lib

prog/obj/dbg/prog
dynlib/dynlib_tester/obj/dbg/dyn_tester

export LD_LIBRARY_PATH=${here}/prog2/prog2_dynlib/obj/dbg
prog2/obj/dbg/prog2

