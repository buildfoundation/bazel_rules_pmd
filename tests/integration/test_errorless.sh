#!/bin/bash
set -eou pipefail

readonly TARGET="pmd_errorless_pmd_test"
readonly OUTPUT_DIR="$(bazel info bazel-bin)/tests/integration"

echo
echo ":: Target with errorless rulesets does not produce error."
echo

set +e
bazel test //tests/integration:${TARGET} > /dev/null

readonly BAZEL_EXIT_CODE=$?
set -e

set -x

test ${BAZEL_EXIT_CODE} = 0

test -f "${OUTPUT_DIR}/${TARGET}_pmd_report.txt"
test -f "${OUTPUT_DIR}/${TARGET}_execution_result.sh"

execution_result=$("${OUTPUT_DIR}/${TARGET}_execution_result.sh"; echo "Exit code: $?")

if [[ "${execution_result}" =~ "Exit code: 0" ]]; then
    echo "PMD execution-result was correctly set."
else
    echo "PMD execution-result was not correctly set. Expected 0, Got: ${execution_result}"
fi
