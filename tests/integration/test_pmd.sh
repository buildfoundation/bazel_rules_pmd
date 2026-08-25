#!/bin/bash
set -euo pipefail

readonly EXPECTED_STATUS="$1"
readonly execution_result="$2"
readonly report_file="${execution_result%_execution_result.sh}_pmd_report.txt"

test -f "${report_file}"
test -f "${execution_result}"

set +e
"${execution_result}"
actual_status=$?
set -e

test "${actual_status}" -eq "${EXPECTED_STATUS}"
