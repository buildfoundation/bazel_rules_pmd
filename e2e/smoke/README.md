# PMD smoke test

This is a downstream Bzlmod module used by CI and the Bazel Central Registry
presubmit. Run it from this directory with:

```sh
bazel test --lockfile_mode=off //...
```
