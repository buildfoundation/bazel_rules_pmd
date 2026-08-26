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
load("@rules_pmd//pmd:defs.bzl", "pmd", "pmd_test")

pmd(
    name = "pmd_analysis",
    srcs = glob(["src/main/java/**/*.java"]),
    rulesets = ["pmd_ruleset.xml"],
)

pmd_test(
    name = "pmd_analysis_test",
    srcs = glob(["src/main/java/**/*.java"]),
    rulesets = ["pmd_ruleset.xml"],
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
        "https://my-mirror.example.com/pmd/pmd-dist-{version}-bin.zip",
        "https://backup.example.com/pmd/pmd-dist-{version}-bin.zip",
    ],
)
use_repo(pmd, "net_sourceforge_pmd")
```

Each template may contain `{version}`, which is replaced with the selected PMD version. Supplying a non-empty list replaces the default GitHub URL; omitting `url_templates`, or passing an empty list, uses that default. Custom URLs must provide the same pinned PMD distribution archive layout (`pmd-bin-{version}/lib`) and the `sha256` of that archive.

This release uses PMD 7.26.0. Custom PMD distributions must be PMD 7.14.0 or newer because the rule uses `--exclude-file-list`; PMD 6 distributions are no longer supported. Existing rulesets may need updates; see the [PMD 7 migration guide](https://docs.pmd-code.org/latest/pmd_userdocs_migrating_to_pmd7.html) and use PMD 7 rule references, for example:

```xml
<rule ref="category/java/bestpractices.xml/AbstractClassWithoutAbstractMethod" />
```

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

Use `pmd` for a build-time analysis whose report is the target output.

By default, violations fail the build; set `fail_on_violation = False` to keep
the report while allowing violations.

```console
$ bazel build //YOUR_PACKAGE:pmd_analysis
```

Use `pmd_test` to run analysis as a test. Violations are replayed in the test
log and reported through the test result:

```console
$ bazel test //YOUR_PACKAGE:pmd_analysis_test
```

Human-readable PMD reports are replayed in the `pmd_test` log, including when
the PMD build action is cached. All reports remain available as build outputs.
