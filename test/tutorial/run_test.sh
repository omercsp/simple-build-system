#!/usr/bin/env bash
here=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
prog=$(basename ${here})
flav=${MODULE_FLAV:-dbg}

cd ${here}
make -j clean
make -j
obj/${flav}/${prog}

