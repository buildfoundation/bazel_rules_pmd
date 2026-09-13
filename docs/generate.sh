#!/bin/bash
set -eou pipefail

bazel build //docs:docs //docs:toolchain_docs //docs:config_docs

mv bazel-bin/docs/rule.md docs/rule.md
mv bazel-bin/docs/toolchain.md docs/toolchain.md
mv bazel-bin/docs/config.md docs/config.md
chmod -x docs/config.md
chmod u+w docs/config.md

chmod -x docs/rule.md
chmod u+w docs/rule.md

chmod -x docs/toolchain.md
chmod u+w docs/toolchain.md
