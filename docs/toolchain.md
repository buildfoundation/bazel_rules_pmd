<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Toolchain declaration.

# pmd_toolchain

Name           | Type                               | Default            | Description
---------------|------------------------------------|--------------------|------------
`name` | [`name`](https://docs.bazel.build/versions/master/build-ref.html#name) | — | A unique name for this target.
`pmd_wrapper` | [`Label`](https://docs.bazel.build/versions/master/skylark/lib/Label.html) | `"@rules_pmd//pmd/wrapper:bin"` | Executable wrapper used to run PMD.
