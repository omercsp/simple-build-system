#!/bin/bash
here=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
flav=${MODULE_FLAV:-dbg}

cd ${here}
make -j clean
make -j
obj/${flav}/tutorial

