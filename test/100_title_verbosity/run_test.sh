#!/usr/bin/env bash
set -e

here=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
cd ${here} || exit 1

echo "----------------- Normal build -----------------"
make clean
make all -j4

echo "---------------- Supress titles ----------------"
export MODULE_MSG_SUPRESS=build_title
make clean
make all -j4
