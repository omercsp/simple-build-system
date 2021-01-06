#!/bin/bash
SCRIPT_PATH=$(readlink -f ${BASH_SOURCE[0]})
SBS_TEST_DIR=$(dirname ${SCRIPT_PATH})
SBS_DIR=${SBS_TEST_DIR}/..
SBS_BINARIES_TEST_DIR=${SBS_TEST_DIR}/binaries
SBS_ORDER_TEST_DIR=${SBS_TEST_DIR}/order

outfile=$(mktemp)
cp ${SBS_DIR}/module.inc.mk ${SBS_BINARIES_TEST_DIR}
cd ${SBS_BINARIES_TEST_DIR}

set -e
echo "Cleaning binaries"
make -j clean  | grep -E "^Cleaning" > ${outfile}
echo "Building binaries"
make -j | grep -E "^Building" >> ${outfile}
echo "Checking binaries output"

export LD_LIBRARY_PATH=${SBS_BINARIES_TEST_DIR}/lib

${SBS_BINARIES_TEST_DIR}/prog/obj/dbg/prog >> ${outfile}
${SBS_BINARIES_TEST_DIR}/dynlib/dynlib_tester/obj/dbg/dyn_tester >> ${outfile}

export LD_LIBRARY_PATH=${SBS_BINARIES_TEST_DIR}/prog2/prog2_dynlib/obj/dbg
${SBS_BINARIES_TEST_DIR}/prog2/obj/dbg/prog2 >> ${outfile}

diff -u ${SBS_TEST_DIR}/expected_binaries_output.txt ${outfile}

cp ${SBS_DIR}/module.inc.mk ${SBS_ORDER_TEST_DIR}
cd ${SBS_ORDER_TEST_DIR}
echo "Cleaning build-order"
make -j clean | sed -e 's/00./00X/g' &> ${outfile}
echo "Building build-order"
make -j | sed -e 's/00./00X/g' &>> ${outfile}
echo "Testing build-order output"
diff -u ${SBS_TEST_DIR}/expected_order_output.txt ${outfile}
