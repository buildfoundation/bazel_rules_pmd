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

skylib_version = "1.3.0"

skylib_sha = "74d544d96f4a5bb630d465ca8bbcfe231e3594e5aae57e1edbf17a6eb3ca2506"

http_archive(
    name = "bazel_skylib",
    sha256 = skylib_sha,
    url = "https://github.com/bazelbuild/bazel-skylib/releases/download/{v}/bazel-skylib-{v}.tar.gz".format(v = skylib_version),
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

# Documenting

## Stardoc

stardoc_version = "0.4.0"

stardoc_sha = "6d07d18c15abb0f6d393adbd6075cd661a2219faab56a9517741f0fc755f6f3c"

http_archive(
    name = "io_bazel_stardoc",
    sha256 = stardoc_sha,
    strip_prefix = "stardoc-{v}".format(v = stardoc_version),
    url = "https://github.com/bazelbuild/stardoc/archive/{v}.tar.gz".format(v = stardoc_version),
)

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()
