load("//pmd:toolchain.bzl", "pmd_toolchain")

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
    "defs.bzl",
    "BUILD.pmd.bazel",
])
