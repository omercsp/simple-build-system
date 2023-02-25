#!/usr/bin/env bash

set -e
SCRIPT_PATH="$(readlink -f ${BASH_SOURCE[0]})"

find . -type d -name obj -exec rm -rf {} +
find . -type d -name lib -exec rm -rf {} +
