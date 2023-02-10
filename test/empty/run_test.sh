#!/usr/bin/env bash
here=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
cd ${here}

make clean
make
