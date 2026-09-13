<!-- Generated with Stardoc: http://skydoc.bazel.build -->

PMD build and test rules.

# pmd

Name           | Type                               | Default            | Description
---------------|------------------------------------|--------------------|------------
`name` | [`name`](https://docs.bazel.build/versions/master/build-ref.html#name) | — | A unique name for this target.
`srcs` | [`[Label]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | — | Source code files.
`config` | [`Label`](https://docs.bazel.build/versions/master/skylark/lib/Label.html) | `None` | PMD configuration. Replaces the registered toolchain's default_config completely when provided.
`report_format` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `"text"` | See [PMD `--format` option](https://docs.pmd-code.org/latest/pmd_userdocs_cli_reference.html)
`srcs_encoding` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `"UTF-8"` | See [PMD `--encoding` option](https://docs.pmd-code.org/latest/pmd_userdocs_cli_reference.html)
`srcs_ignore` | [`[Label]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | `[]` | Source code files to ignore.
`srcs_language` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `"java"` | See [PMD `--force-language` option](https://docs.pmd-code.org/latest/pmd_userdocs_cli_reference.html)
`srcs_language_version` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `""` | PMD language version (for example, `1.8` for Java); see [PMD `--use-version` option](https://docs.pmd-code.org/latest/pmd_userdocs_cli_reference.html)


# pmd_test

Name           | Type                               | Default            | Description
---------------|------------------------------------|--------------------|------------
`name` | [`name`](https://docs.bazel.build/versions/master/build-ref.html#name) | — | A unique name for this target.
`srcs` | [`[Label]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | — | Source code files.
`config` | [`Label`](https://docs.bazel.build/versions/master/skylark/lib/Label.html) | `None` | PMD configuration. Replaces the registered toolchain's default_config completely when provided.
`report_format` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `"text"` | See [PMD `--format` option](https://docs.pmd-code.org/latest/pmd_userdocs_cli_reference.html)
`srcs_encoding` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `"UTF-8"` | See [PMD `--encoding` option](https://docs.pmd-code.org/latest/pmd_userdocs_cli_reference.html)
`srcs_ignore` | [`[Label]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | `[]` | Source code files to ignore.
`srcs_language` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `"java"` | See [PMD `--force-language` option](https://docs.pmd-code.org/latest/pmd_userdocs_cli_reference.html)
`srcs_language_version` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `""` | PMD language version (for example, `1.8` for Java); see [PMD `--use-version` option](https://docs.pmd-code.org/latest/pmd_userdocs_cli_reference.html)
