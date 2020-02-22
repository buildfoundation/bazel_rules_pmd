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

skylib_version = "1.0.2"

skylib_sha = "97e70364e9249702246c0e9444bccdc4b847bed1eb03c5a3ece4f83dfe6abc44"

http_archive(
    name = "bazel_skylib",
    sha256 = skylib_sha,
    url = "https://github.com/bazelbuild/bazel-skylib/releases/download/{v}/bazel-skylib-{v}.tar.gz".format(v = skylib_version),
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()
