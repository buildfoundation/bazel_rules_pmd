<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# Attributes

Name           | Type                               | Default            | Description
---------------|------------------------------------|--------------------|------------
`name` | [`name`](https://docs.bazel.build/versions/master/build-ref.html#name) | — | A unique name for this target.
`fail_on_violation` | [`bool`](https://docs.bazel.build/versions/master/skylark/lib/bool.html) | `True` | See [PMD `-failOnViolation` option](https://pmd.github.io/latest/pmd_userdocs_cli_reference.html)
`report_format` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `"text"` | See [PMD `-format` option](https://pmd.github.io/latest/pmd_userdocs_cli_reference.html)
`rules_minimum_priority` | [`int`](https://docs.bazel.build/versions/master/skylark/lib/int.html) | `5` | See [PMD `-minimumpriority` option](https://pmd.github.io/latest/pmd_userdocs_cli_reference.html)
`rulesets` | [`[Label]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | — | Ruleset files.
`srcs` | [`[Label]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | — | Source code files.
`srcs_encoding` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `"UTF-8"` | See [PMD `-encoding` option](https://pmd.github.io/latest/pmd_userdocs_cli_reference.html)
`srcs_ignore` | [`[Label]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | `[]` | Source code files to ignore.
`srcs_language` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `"java"` | See [PMD `-language` option](https://pmd.github.io/latest/pmd_userdocs_cli_reference.html)
`srcs_language_version` | [`string`](https://docs.bazel.build/versions/master/skylark/lib/string.html) | `""` | See [PMD `-version` option](https://pmd.github.io/latest/pmd_userdocs_cli_reference.html)
`threads_count` | [`int`](https://docs.bazel.build/versions/master/skylark/lib/int.html) | `1` | See [PMD `-threads` option](https://pmd.github.io/latest/pmd_userdocs_cli_reference.html)
