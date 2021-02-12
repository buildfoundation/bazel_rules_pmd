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

skylib_version = "1.0.3"

skylib_sha = "1c531376ac7e5a180e0237938a2536de0c54d93f5c278634818e0efc952dd56c"

http_archive(
    name = "bazel_skylib",
    sha256 = skylib_sha,
    url = "https://github.com/bazelbuild/bazel-skylib/releases/download/{v}/bazel-skylib-{v}.tar.gz".format(v = skylib_version),
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()
