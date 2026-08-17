# `bazel_rules_pmd`

The [PMD](https://pmd.github.io/) (a static analysis tool) integration
for [the Bazel build system](https://bazel.build).

## Usage

### `MODULE.bazel` Configuration

```starlark
bazel_dep(name = "rules_pmd", version = "...")
```

Please refer to [GitHub releases](https://github.com/buildfoundation/bazel_rules_pmd/releases) for the available versions.

### `BUILD` Configuration

Once declared in the `MODULE.bazel` file, the rule can be loaded in the `BUILD` file.

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
use_repo(pmd, "net_sourceforge_pmd")
```

See [available attributes](docs/rule.md).

### Execution

```console
$ bazel build //YOUR_PACKAGE:pmd_analysis
```
