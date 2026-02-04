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

skylib_version = "1.7.1"

skylib_sha = "bc283cdfcd526a52c3201279cda4bc298652efa898b10b4db0837dc51652756f"

http_archive(
    name = "bazel_skylib",
    sha256 = skylib_sha,
    url = "https://github.com/bazelbuild/bazel-skylib/releases/download/{v}/bazel-skylib-{v}.tar.gz".format(v = skylib_version),
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

# Documenting

## Stardoc

stardoc_version = "0.7.2"

stardoc_sha = "0e1ed4a98f26e718776bd64d053d02bb34d98572ccd03d6ba355112a1205706b"

http_archive(
    name = "io_bazel_stardoc",
    sha256 = stardoc_sha,
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/stardoc/releases/download/{v}/stardoc-{v}.tar.gz".format(v = stardoc_version),
        "https://github.com/bazelbuild/stardoc/releases/download/{v}/stardoc-{v}.tar.gz".format(v = stardoc_version),
    ],
)

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()

load("@rules_java//java:rules_java_deps.bzl", "rules_java_dependencies")

rules_java_dependencies()

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()

load("@rules_jvm_external//:repositories.bzl", "rules_jvm_external_deps")

rules_jvm_external_deps()

load("@rules_jvm_external//:setup.bzl", "rules_jvm_external_setup")

rules_jvm_external_setup()

load("@io_bazel_stardoc//:deps.bzl", "stardoc_external_deps")

stardoc_external_deps()

load("@stardoc_maven//:defs.bzl", stardoc_pinned_maven_install = "pinned_maven_install")

stardoc_pinned_maven_install()

# Linting

## Buildifier

http_archive(
    name = "buildifier_prebuilt",
    sha256 = "5dbf72e4f93917edfb91f53958d6289736adb845b2b89dbfb9bfc199a492030c",
    strip_prefix = "buildifier-prebuilt-8.0.1",
    url = "https://github.com/keith/buildifier-prebuilt/archive/refs/tags/8.0.1.tar.gz",
)

load("@buildifier_prebuilt//:deps.bzl", "buildifier_prebuilt_deps")

buildifier_prebuilt_deps()

load("@buildifier_prebuilt//:defs.bzl", "buildifier_prebuilt_register_toolchains")

buildifier_prebuilt_register_toolchains()
