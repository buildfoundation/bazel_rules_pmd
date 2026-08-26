#!/bin/bash
set -euo pipefail

readonly clean_report="$1"
readonly no_fail_report="$2"

test -f "${clean_report}"
test -f "${no_fail_report}"
test ! -s "${clean_report}"
grep -Fq "AbstractClassWithoutAbstractMethod" "${no_fail_report}"
