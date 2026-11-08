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
# quality/BUILD
load("@rules_pmd//pmd:config.bzl", "pmd_config")

pmd_config(
    name = "pmd_config",
    rulesets = ["pmd_ruleset.xml"],
    visibility = ["//visibility:public"],
)
```

```starlark
# YOUR_PACKAGE/BUILD
load("@rules_pmd//pmd:defs.bzl", "pmd", "pmd_test")

pmd(
    name = "pmd_analysis",
    srcs = glob(["src/main/java/**/*.java"]),
    config = "//quality:pmd_config",
)

pmd_test(
    name = "pmd_analysis_test",
    srcs = glob(["src/main/java/**/*.java"]),
    config = "//quality:pmd_config",
)
```

`pmd_config` holds the analysis policy shared by `pmd` and `pmd_test`:
`rulesets`, `rules_minimum_priority` (default `5`), and `threads_count`
(default `1`). Like any target, a config used from other packages needs
`visibility`. The selected config is authoritative: an explicit `config`
replaces the default completely, including default-valued settings; nothing is
merged or inherited per field. Different targets can use different configs.

If a target omits `config`, the registered PMD toolchain's `default_config` is
used. To set a repository-wide default, register a toolchain that references
your config (see [Toolchain](#toolchain)):

```starlark
pmd_toolchain(
    name = "pmd_toolchain_impl",
    default_config = "//quality:pmd_config",
)
```

The bundled default config has no rulesets, and a selected config must provide
at least one ruleset file; otherwise analysis fails with an error naming the
selected config.

The remaining options stay on each rule: `srcs`, `srcs_ignore`,
`srcs_encoding` (default `UTF-8`), `srcs_language` (default `java`; allowed
values are `apex`, `ecmascript`, `java`, `jsp`, `modelica`, `plsql`, `scala`,
`vf`, `vm`, and `xml`), `srcs_language_version`, `report_format`, and
`fail_on_violation` (default `True`).

See the [rule attributes](docs/rule.md), [config attributes](docs/config.md),
and [toolchain attributes](docs/toolchain.md) for the generated API reference.

#### Migrating from 0.4.x

Move `rulesets`, `rules_minimum_priority`, and `threads_count` from each `pmd`
or `pmd_test` target into a `pmd_config` target, then reference it with
`config` or set it as the toolchain's `default_config`. `fail_on_violation`
is unchanged. The toolchain's `jvm_flags` attribute was removed; use
`--host_jvmopt` instead (see [JVM options](#jvm-options)).

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

This release uses PMD 7.29.0. Custom PMD distributions must be PMD 7.14.0 or newer because the rule uses `--exclude-file-list`; PMD 6 distributions are no longer supported. Existing rulesets may need updates; see the [PMD 7 migration guide](https://docs.pmd-code.org/latest/pmd_userdocs_migrating_to_pmd7.html) and use PMD 7 rule references, for example:

```xml
<rule ref="category/java/bestpractices.xml/AbstractClassWithoutAbstractMethod" />
```

#### Toolchain

The PMD toolchain supplies the default config (`default_config`, which has no
rulesets) and the executable (`pmd_wrapper`, `@rules_pmd//pmd/wrapper:bin` by
default). To change either, register a custom toolchain:

```starlark
# BUILD
load("@rules_pmd//pmd:toolchain.bzl", "pmd_toolchain")

pmd_toolchain(
    name = "pmd_toolchain_impl",
    default_config = "//quality:pmd_config",
)

toolchain(
    name = "pmd_toolchain",
    toolchain = ":pmd_toolchain_impl",
    toolchain_type = "@rules_pmd//pmd:toolchain_type",
)
```

Register it from `MODULE.bazel` with `register_toolchains("//:pmd_toolchain")`.
Toolchains registered by the root module take precedence over the bundled
default. A custom `pmd_wrapper` is built in the exec configuration and receives the PMD
wrapper CLI arguments, not the raw PMD CLI.

#### JVM options

The wrapper is an exec-configured `java_binary`, so set its JVM options with
Bazel's `--host_jvmopt`, for example in `.bazelrc`:

```
common --host_jvmopt=-Xmx1g
```

This applies to every exec-configured `java_binary`, not only PMD.
`--host_jvm_args` configures the Bazel server JVM instead.

### Execution

Use `pmd` for a build-time analysis whose report is the target output.

By default, violations fail the build; set `fail_on_violation = False` on the
target to keep the report while allowing violations.

```console
$ bazel build //YOUR_PACKAGE:pmd_analysis
```

Use `pmd_test` to run analysis as a test. Violations are replayed in the test
log and reported through the test result:

```console
$ bazel test //YOUR_PACKAGE:pmd_analysis_test
```

Human-readable PMD reports are replayed in the `pmd_test` log, including when
the PMD build action is cached. All reports remain available as build outputs. SARIF artifact locations are relative to the Bazel execution root.
