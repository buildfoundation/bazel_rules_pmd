load("//pmd:config.bzl", "pmd_config")
load("//pmd:toolchain.bzl", "pmd_toolchain")

pmd_config(
    name = "default_config",
    visibility = ["//visibility:public"],
)

toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)

pmd_toolchain(
    name = "default_toolchain_impl",
)

toolchain(
    name = "default_toolchain",
    toolchain = ":default_toolchain_impl",
    toolchain_type = "//pmd:toolchain_type",
)

exports_files([
    "config.bzl",
    "defs.bzl",
    "BUILD.pmd.bazel",
    "execution_result.sh.tpl",
    "toolchain.bzl",
])
