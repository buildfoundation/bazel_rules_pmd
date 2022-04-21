# `bazel_rules_pmd`

The [PMD](https://pmd.github.io/) (a static analysis tool) integration
for [the Bazel build system](https://bazel.build).

## Usage

### `WORKSPACE` Configuration

Declare the rule in the `WORKSPACE` file.
Please refer to [GitHub releases](https://github.com/buildfoundation/bazel_rules_pmd/releases) for the version and the SHA-256 hashsum.

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

### Using a custom version of PMD

Building on the default WORKSPACE configuration, you can use the `version` macro to define a custom PMD version to supply. 

PMD bin releases are downloaded from [https://github.com/pmd/pmd/releases](https://github.com/pmd/pmd/releases).

Example:

```starlark

load("@rules_pmd//pmd:dependencies.bzl", "rules_pmd_dependencies", "pmd_version")
rules_pmd_dependencies(pmd_release = pmd_version(version = "6.44.0", sha256 = "7e6dceba88529a90b2b33c8f05b53bc409fa9eab79be592c875f6bd996aaade7"))

load("@rules_pmd//pmd:toolchains.bzl", "rules_pmd_toolchains")
rules_pmd_toolchains()
```

### `BUILD` Configuration

Once declared in the `WORSKPACE` file, the rule can be loaded in the `BUILD` file.

```starlark
load("@rules_pmd//pmd:defs.bzl", "pmd")

pmd(
    name = "pmd_analysis",
    srcs = glob(["src/main/java/**/*.java"]),
)
```

See [available attributes](docs/rule.md).

### Execution

```console
$ bazel build //YOUR_PACKAGE:pmd_analysis
```
