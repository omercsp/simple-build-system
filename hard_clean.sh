#!/bin/bash
SCRIPT_PATH="$(readlink -f ${BASH_SOURCE[0]})"
SBS_DIR=$(dirname $SCRIPT_PATH)

find ${SBS_DIR}/test -type d -name obj -exec rm -rf {} +
