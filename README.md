# `bazel_rules_pmd`

The [PMD](https://pmd.github.io/) (a static analysis tool) integration
for [the Bazel build system](https://bazel.build).

## Usage

### `MODULE.bazel` Configuration

```starlark
bazel_dep(name = "rules_pmd", version = "...")
```

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

### `BUILD` Configuration

Once declared in the `WORSKPACE` file, the rule can be loaded in the `BUILD` file.

```starlark
load("@rules_pmd//pmd:defs.bzl", "pmd_test")

pmd_test(
    name = "pmd_analysis_test",
    srcs = glob(["src/main/java/**/*.java"]),
)
```

#### PMD Version

Change the `MODULE.bazel` file:

```python
pmd = use_extension("//pmd:extensions.bzl", "pmd")
pmd.pmd_version(
    version = "x.x.x",
    sha256 = "x.x.x.sha256",
)
use_repo(pmd, "pmd_cli_all")
```

Or change the `WORKSPACE` file:

```python
load("@rules_pmd//pmd:versions.bzl", "pmd_version")
load("@rules_pmd//pmd:dependencies.bzl", "rules_pmd_dependencies")

rules_pmd_dependencies(
    pmd_version = pmd_version(
        version = "x.x.x",
        sha256 = "x.x.x.sha256",
    )
)
```

See [available attributes](docs/rule.md).

### Execution

```console
$ bazel build //YOUR_PACKAGE:pmd_analysis
```
