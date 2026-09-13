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
load("@rules_pmd//pmd:config.bzl", "pmd_config")

pmd_config(
    name = "pmd_profile",
    rulesets = ["//quality:pmd_ruleset.xml"],
)

pmd(
    name = "pmd_analysis",
    srcs = glob(["src/main/java/**/*.java"]),
    config = ":pmd_profile",
)

pmd_test(
    name = "pmd_analysis_test",
    srcs = glob(["src/main/java/**/*.java"]),
    config = ":pmd_profile",
)
```

`pmd_config` centralizes the analysis policy shared by `pmd` and `pmd_test`.
The `config` attribute references this ordinary configuration target; no
registration is needed. If omitted, the registered PMD toolchain's
`default_config` is used. Bazel always selects the executable toolchain.

The bundled default configuration intentionally has no rulesets. A selected
configuration must provide a non-empty `rulesets` set; otherwise analysis
fails. The selected profile is authoritative: `rulesets`,
`rules_minimum_priority`, `fail_on_violation`, and `threads_count` are not
rule-level overrides and are not merged with a profile.

Multiple profiles can coexist when targets need different policy:

```starlark
pmd_config(name = "strict_profile", rulesets = ["//quality:strict.xml"])
pmd_config(name = "legacy_profile", rulesets = ["//quality:legacy.xml"])

pmd(
    name = "strict_analysis",
    srcs = ["Strict.java"],
    config = ":strict_profile",
)
pmd_test(
    name = "legacy_analysis",
    srcs = ["Legacy.java"],
    config = ":legacy_profile",
)
```

To supply a repository-wide default, reference the configuration from a
toolchain and register that toolchain from `MODULE.bazel`:

```starlark
# BUILD
load("@rules_pmd//pmd:toolchain.bzl", "pmd_toolchain")

pmd_toolchain(
    name = "pmd_toolchain_impl",
    default_config = ":pmd_profile",
)

toolchain(
    name = "pmd_toolchain",
    toolchain = ":pmd_toolchain_impl",
    toolchain_type = "@rules_pmd//pmd:toolchain_type",
)
```

```starlark
# MODULE.bazel
register_toolchains("//:pmd_toolchain")
```

Configurations can also set `rules_minimum_priority` (default `5`),
`fail_on_violation` (default `True`), and `threads_count` (default `1`).
An explicit `config` replaces the entire default configuration, including
ordinary default-valued settings; nothing is merged or inherited per field.

The toolchain owns the public `pmd_wrapper` executable (default
`@rules_pmd//pmd/wrapper:bin`). The wrapper receives the PMD wrapper CLI
arguments; it is not the raw PMD CLI. `pmd_wrapper` is resolved in exec
configuration automatically; a custom value only needs to be an executable
target.
See the [rule attributes](docs/rule.md), [config attributes](docs/config.md), and [toolchain attributes](docs/toolchain.md)
for the generated API reference.

The source and output choices stay on each rule: `srcs`, `srcs_ignore`,
`srcs_encoding` (default `UTF-8`), `srcs_language` (default `java`; allowed
values are `apex`, `ecmascript`, `java`, `jsp`, `modelica`, `plsql`, `scala`,
`vf`, `vm`, and `xml`), `srcs_language_version`, and `report_format`. PMD is
polyglot, so targets may need different source metadata, and report format is
an output choice for the individual target.

Migration from the previous API: move `rulesets`, `rules_minimum_priority`,
`fail_on_violation`, and `threads_count` from each `pmd` or `pmd_test` target
into a `pmd_config` target, then reference it with `config` or the toolchain's
`default_config`. The per-target `pmd_toolchain` selector is not supported. Those
four rule attributes were removed; there is no per-target override or merge.

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

The PMD version, checksum, and download URL templates remain Bzlmod extension
settings; they are not profile attributes.

#### JVM options

The `jvm_flags` profile attribute was removed. The PMD wrapper is an
exec-configured `java_binary`; use Bazel's native execution-JVM option when it
needs more heap:

```console
$ bazel build --host_jvmopt=-Xmx512m //YOUR_PACKAGE:pmd_analysis
```

`--host_jvm_args` configures the Bazel server JVM, not the PMD execution JVM.

### Execution

Use `pmd` for a build-time analysis whose report is the target output.

By default, violations fail the build; set `fail_on_violation = False` on the
selected `pmd_toolchain` profile to keep the report while allowing violations.

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
