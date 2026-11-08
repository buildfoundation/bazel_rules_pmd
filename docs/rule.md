<!-- Generated with Stardoc: http://skydoc.bazel.build -->

PMD build and test rules.

# pmd

Name           | Type                               | Default            | Description
---------------|------------------------------------|--------------------|------------
`name` | [`name`](https://docs.bazel.build/versions/master/build-ref.html#name) | — | A unique name for this target.
`srcs` | [`[Label]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | — | Source code files.
`fail_on_violation` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `True` | See [PMD `--fail-on-violation` option](https://docs.pmd-code.org/latest/pmd_userdocs_cli_reference.html)
`report_format` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `"text"` | See [PMD `--format` option](https://docs.pmd-code.org/latest/pmd_userdocs_cli_reference.html)
`rules_minimum_priority` | [`int`](https://docs.bazel.build/versions/master/skylark/lib/int.html) | `5` | See [PMD `--minimum-priority` option](https://docs.pmd-code.org/latest/pmd_userdocs_cli_reference.html)
`rulesets` | [`[Label]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | — | Ruleset files.
`srcs_encoding` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `"UTF-8"` | See [PMD `--encoding` option](https://docs.pmd-code.org/latest/pmd_userdocs_cli_reference.html)
`srcs_ignore` | [`[Label]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | `[]` | Source code files to ignore.
`srcs_language` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `"java"` | See [PMD `--force-language` option](https://docs.pmd-code.org/latest/pmd_userdocs_cli_reference.html)
`srcs_language_version` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `""` | PMD language version (for example, `1.8` for Java); see [PMD `--use-version` option](https://docs.pmd-code.org/latest/pmd_userdocs_cli_reference.html)
`threads_count` | [`int`](https://docs.bazel.build/versions/master/skylark/lib/int.html) | `1` | See [PMD `--threads` option](https://docs.pmd-code.org/latest/pmd_userdocs_cli_reference.html)


# pmd_test

Name           | Type                               | Default            | Description
---------------|------------------------------------|--------------------|------------
`name` | [`name`](https://docs.bazel.build/versions/master/build-ref.html#name) | — | A unique name for this target.
`srcs` | [`[Label]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | — | Source code files.
`fail_on_violation` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `True` | See [PMD `--fail-on-violation` option](https://docs.pmd-code.org/latest/pmd_userdocs_cli_reference.html)
`report_format` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `"text"` | See [PMD `--format` option](https://docs.pmd-code.org/latest/pmd_userdocs_cli_reference.html)
`rules_minimum_priority` | [`int`](https://docs.bazel.build/versions/master/skylark/lib/int.html) | `5` | See [PMD `--minimum-priority` option](https://docs.pmd-code.org/latest/pmd_userdocs_cli_reference.html)
`rulesets` | [`[Label]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | — | Ruleset files.
`srcs_encoding` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `"UTF-8"` | See [PMD `--encoding` option](https://docs.pmd-code.org/latest/pmd_userdocs_cli_reference.html)
`srcs_ignore` | [`[Label]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | `[]` | Source code files to ignore.
`srcs_language` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `"java"` | See [PMD `--force-language` option](https://docs.pmd-code.org/latest/pmd_userdocs_cli_reference.html)
`srcs_language_version` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `""` | PMD language version (for example, `1.8` for Java); see [PMD `--use-version` option](https://docs.pmd-code.org/latest/pmd_userdocs_cli_reference.html)
`threads_count` | [`int`](https://docs.bazel.build/versions/master/skylark/lib/int.html) | `1` | See [PMD `--threads` option](https://docs.pmd-code.org/latest/pmd_userdocs_cli_reference.html)
