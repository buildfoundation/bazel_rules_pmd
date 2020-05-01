#!/bin/bash
set -eou pipefail

readonly TARGET="pmd_errorless"
readonly OUTPUT_DIR="$(bazel info bazel-bin)/tests/integration"

echo
echo ":: Target with errorless rulesets does not produce error."
echo

set +e
bazel build //tests/integration:${TARGET} > /dev/null

readonly BAZEL_EXIT_CODE=$?
set -e

set -x

test ${BAZEL_EXIT_CODE} = 0

test -f "${OUTPUT_DIR}/${TARGET}_pmd_report.txt"
