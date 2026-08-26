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
pmd = use_extension("@rules_pmd//pmd:extensions.bzl", "pmd")
pmd.pmd_version(
    version = "x.x.x",
    sha256 = "x.x.x.sha256",
)
use_repo(pmd, "net_sourceforge_pmd")
```

To download PMD from a custom location (for example, an internal mirror), provide a `url_templates` list:

```python
pmd = use_extension("@rules_pmd//pmd:extensions.bzl", "pmd")
pmd.pmd_version(
    version = "x.x.x",
    sha256 = "x.x.x.sha256",
    url_templates = [
        "https://my-mirror.example.com/pmd/pmd-bin-{version}.zip",
        "https://backup.example.com/pmd/pmd-bin-{version}.zip",
    ],
)
use_repo(pmd, "net_sourceforge_pmd")
```

Each template may contain `{version}`, which is replaced with the selected PMD version. Supplying a non-empty list replaces the default GitHub URL; omitting `url_templates`, or passing an empty list, uses that default. Custom URLs must provide the same pinned PMD distribution archive layout (`pmd-bin-{version}/lib`) and the `sha256` of that archive.

See [available attributes](docs/rule.md).

#### JVM Flags

The default PMD toolchain supplies no JVM flags, preserving the Java runtime defaults. To configure flags, define and register a custom toolchain:

```starlark
# BUILD
load("@rules_pmd//pmd:toolchain.bzl", "pmd_toolchain")

pmd_toolchain(
    name = "pmd_toolchain_impl",
    jvm_flags = ["-Xmx1g", "-Dexample.property=value"],
)

toolchain(
    name = "pmd_toolchain",
    toolchain = ":pmd_toolchain_impl",
    toolchain_type = "@rules_pmd//pmd:toolchain_type",
)
```

Register it from `MODULE.bazel` with `register_toolchains("//:pmd_toolchain")`.

### Execution

```console
$ bazel test //YOUR_PACKAGE:pmd_analysis_test
```

Human-readable PMD reports are replayed in the test log, including when the PMD
build action is cached. All reports remain available as build outputs.

### Windows

PMD test execution requires Bash on Windows, discoverable on `PATH`. See
[Bazel's Windows installation
documentation](https://bazel.build/install/windows) for setup. CI covers Linux
and Windows across Bazel 8.x, 9.x, and rolling.
