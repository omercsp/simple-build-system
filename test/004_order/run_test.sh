#!/usr/bin/env bash
here=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
cd ${here} || exit 1

set -e
tmp_file=$(mktemp)
make -j | sed -e '/^Building/d' -e 's/[0-9]/X/' &> ${tmp_file}

grep Starting ${tmp_file}
echo "-----------------"
grep Finished ${tmp_file}

rm ${tmp_file}
