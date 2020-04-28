#!/bin/bash
set -eou pipefail

TARGET="pmd_error"
OUTPUT_DIR="$(bazel info bazel-bin)/tests/integration/"

echo ":: Target with error rulesets produces error."

set +e
bazel build //tests/integration:${TARGET} > /dev/null
BAZEL_EXIT_CODE=$?
set -e

set -x

test ${BAZEL_EXIT_CODE} != 0

test -f "${OUTPUT_DIR}/${TARGET}_pmd_report.txt"
