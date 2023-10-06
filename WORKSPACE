workspace(name = "rules_pmd")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Runtime

## Dependencies

load("//pmd:dependencies.bzl", "rules_pmd_dependencies")

rules_pmd_dependencies()

## Toolchains

load("//pmd:toolchains.bzl", "rules_pmd_toolchains")

rules_pmd_toolchains()

# Testing

## Skylib

skylib_version = "1.4.1"

skylib_sha = "66ffd9315665bfaafc96b52278f57c7e2dd09f5ede279ea6d39b2be471e7e3aa"

http_archive(
    name = "bazel_skylib",
    sha256 = skylib_sha,
    url = "https://github.com/bazelbuild/bazel-skylib/releases/download/{v}/bazel-skylib-{v}.tar.gz".format(v = skylib_version),
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

# Documenting

## Stardoc

stardoc_version = "0.5.3"

stardoc_sha = "fc95cd29422f1d67395352804d03252aa77714e88dcbefd4d3b070d70ed75de7"

http_archive(
    name = "io_bazel_stardoc",
    sha256 = stardoc_sha,
    strip_prefix = "stardoc-{v}".format(v = stardoc_version),
    url = "https://github.com/bazelbuild/stardoc/archive/{v}.tar.gz".format(v = stardoc_version),
)

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()

# Linting

## Buildifier

http_archive(
    name = "buildifier_prebuilt",
    sha256 = "b3fd85ae7e45c2f36bce52cfdbdb6c20261761ea5928d1686edc8873b0d0dad0",
    strip_prefix = "buildifier-prebuilt-5.1.0",
    url = "http://github.com/keith/buildifier-prebuilt/archive/5.1.0.tar.gz",
)

load("@buildifier_prebuilt//:deps.bzl", "buildifier_prebuilt_deps")

buildifier_prebuilt_deps()

load("@buildifier_prebuilt//:defs.bzl", "buildifier_prebuilt_register_toolchains")

buildifier_prebuilt_register_toolchains()
