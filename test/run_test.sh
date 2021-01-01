#!/bin/bash
SCRIPT_PATH=$(readlink -f ${BASH_SOURCE[0]})
SCRIPT_DIR=$(dirname ${SCRIPT_PATH})
PROJECT_DIR=${SCRIPT_DIR}/..

outfile=$(mktemp)
cd ${PROJECT_DIR}

set -e
echo "Cleaning binaries"
make -j clean  | grep -E "^Cleaning" > ${outfile}
echo "Building binaries"
make -j | grep -E "^Building" >> ${outfile}
echo "Checking binaries output"

export LD_LIBRARY_PATH=${PROJECT_DIR}/lib

${PROJECT_DIR}/prog/obj/dbg/prog >> ${outfile}
${PROJECT_DIR}/dynlib/dynlib_tester/obj/dbg/dyn_tester >> ${outfile}

diff -u ${SCRIPT_DIR}/expected_output.txt ${outfile}

cd ${PROJECT_DIR}/order
echo "Cleaning build-order"
make -j clean | sed -e 's/00./00X/g' &> ${outfile}
echo "Building build-order"
make -j | sed -e 's/00./00X/g' &>> ${outfile}
echo "Testing build-order output"
diff -u ${SCRIPT_DIR}/expected_order_output.txt ${outfile}
