#!/usr/bin/env bash
set -e

here=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
cd ${here} || exit 1

# Clean up any previous test artifacts, to prevnet the same problem this parallel
# rebuild warning is issued about, i.e. clean vs. build in parallel.
set -e
make clean &> /dev/null

echo "----------------- Parallel rebuild, expecting warning -----------------"
make clean all -j4

echo "--------------- Sequential rebuild, expecting no warning---------------"
make clean all

echo
echo "--------------- Separated rebuild, expecting no warning ---------------"
make clean -j4
make all -j4

make clean &> /dev/null
echo
echo "--------------- Parallel rebuild, supress warning (env) ---------------"
MODULE_MSG_SUPRESS=parallel_rebuild_wrn make clean all -j

make clean &> /dev/null
echo
echo "------------- Parallel rebuild, supress warning (make) ----------------"
make clean all -j MODULE_MSG_SUPRESS=parallel_rebuild_wrn
