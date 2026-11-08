<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Reusable PMD analysis policy.

# pmd_config

Name           | Type                               | Default            | Description
---------------|------------------------------------|--------------------|------------
`name` | [`name`](https://docs.bazel.build/versions/master/build-ref.html#name) | — | A unique name for this target.
`rules_minimum_priority` | [`int`](https://docs.bazel.build/versions/master/skylark/lib/int.html) | `5` | PMD minimum rule priority (1 to 5).
`rulesets` | [`[Label]`](https://docs.bazel.build/versions/master/skylark/lib/list.html) | `[]` | PMD ruleset files. Must resolve to at least one file when used by a PMD target.
`threads_count` | [`int`](https://docs.bazel.build/versions/master/skylark/lib/int.html) | `1` | Number of PMD analysis threads.


<a id="PmdConfigInfo"></a>

## PmdConfigInfo

<pre>
load("@rules_pmd//pmd:config.bzl", "PmdConfigInfo")

PmdConfigInfo(<a href="#PmdConfigInfo-rulesets">rulesets</a>, <a href="#PmdConfigInfo-rules_minimum_priority">rules_minimum_priority</a>, <a href="#PmdConfigInfo-threads_count">threads_count</a>)
</pre>

Complete PMD analysis policy, selected without per-field inheritance.

**FIELDS**

| Name  | Description |
| :------------- | :------------- |
| <a id="PmdConfigInfo-rulesets"></a>rulesets |  Resolved ruleset files (list of File).    |
| <a id="PmdConfigInfo-rules_minimum_priority"></a>rules_minimum_priority |  Minimum rule priority.    |
| <a id="PmdConfigInfo-threads_count"></a>threads_count |  Number of analysis threads.    |
