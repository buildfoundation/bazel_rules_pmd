#!/bin/bash
set -euo pipefail

readonly EXPECTED_STATUS="$1"
readonly execution_result="$2"
readonly report_extension="${3:-txt}"
readonly report_file="${execution_result%_execution_result.sh}_pmd_report.${report_extension}"
readonly output_file="${TEST_TMPDIR}/pmd-output"

test -f "${report_file}"
test -f "${execution_result}"

set +e
"${execution_result}" >"${output_file}" 2>&1
actual_status=$?
set -e

test "${actual_status}" -eq "${EXPECTED_STATUS}"

case "${report_extension}" in
    txt|textcolor|textpad)
        cmp "${report_file}" "${output_file}"
        ;;
    sarif)
        test -s "${report_file}"
        grep -Fq '"version": "2.1.0"' "${report_file}"
        grep -Fq '"ruleId": "AbstractClassWithoutAbstractMethod"' "${report_file}"
        grep -Fq '"uri": "./tests/integration/src/main/java/A.java"' "${report_file}"
        test ! -s "${output_file}"
        ;;
    xml|json)
        grep -Eq 'timestamp"?[=:] ?"1970-01-01T00:00:00.000"' "${report_file}"
        test ! -s "${output_file}"
        ;;
    *)
        test ! -s "${output_file}"
        ;;
esac
