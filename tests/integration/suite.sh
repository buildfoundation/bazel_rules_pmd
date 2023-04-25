#!/bin/bash
set -eou pipefail

readonly GENERATED_CODE_DIR="tests/integration/src/main/java/generated"

readonly BAZEL_RC=".bazelrc"
readonly BAZEL_RC_ORIGINAL=".bazelrc.original"

cp "${BAZEL_RC}" "${BAZEL_RC_ORIGINAL}"

for STRATEGY in "local"; do
    echo ":: Executing with the [${STRATEGY}] strategy."
    cp "${BAZEL_RC_ORIGINAL}" "${BAZEL_RC}"
    echo "test --strategy=PMD=${STRATEGY}" >> "${BAZEL_RC}"

    # Generate a bit of code to keep Bazel working instead of pulling from cache to check strategies execution.
    rm -rf "${GENERATED_CODE_DIR}" && mkdir -p "${GENERATED_CODE_DIR}"
    touch "${GENERATED_CODE_DIR}/${STRATEGY}.java"

    for TEST in tests/integration/test_*.sh; do
        bash $TEST
    done
done

trap "rm -rf ${GENERATED_CODE_DIR} && mv ${BAZEL_RC_ORIGINAL} ${BAZEL_RC}" EXIT

echo
echo ":: Success!"
