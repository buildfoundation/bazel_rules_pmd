#!/bin/bash
set -eou pipefail

bazel build //docs:docs //docs:toolchain_docs //docs:config_docs

for doc in rule toolchain config; do
    mv "bazel-bin/docs/${doc}.md" "docs/${doc}.md"
    chmod -x "docs/${doc}.md"
    chmod u+w "docs/${doc}.md"
done
