#!/usr/bin/env bash
here=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
xeet run -c "${here}/test/xeet.yaml" "$@"
