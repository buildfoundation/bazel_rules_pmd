# `bazel_rules_pmd`

The [PMD](https://pmd.github.io/) (a static analysis tool) integration
for [the Bazel build system](https://bazel.build).

## Usage

### `WORKSPACE` Configuration

```starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

rules_pmd_version = "REPLACE_ME"
rules_pmd_sha = "REPLACE_ME"

http_archive(
    name = "rules_pmd",
    sha256 = rules_pmd_sha,
    strip_prefix = "bazel_rules_pmd-{v}".format(v = rules_pmd_version),
    url = "https://github.com/buildfoundation/bazel_rules_pmd/archive/v{v}.tar.gz".format(v = rules_pmd_version),
)

load("@rules_pmd//pmd:dependencies.bzl", "rules_pmd_dependencies")
rules_pmd_dependencies()

load("@rules_pmd//pmd:toolchains.bzl", "rules_pmd_toolchains")
rules_pmd_toolchains()
```

### `BUILD` Configuration

```starlark
load("@rules_pmd//pmd:defs.bzl", "pmd")

pmd(
    name = "pmd_analysis",
    srcs = glob(["src/main/java/**/*.java"]),
)
```

### Execution

```console
$ bazel build //YOUR_PACKAGE:pmd_analysis
```
