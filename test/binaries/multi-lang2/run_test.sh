#!/usr/bin/env bash
here=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
prog=$(basename ${here})

cd ${here}
make -j clean
make -j
obj/dbg/${prog}

