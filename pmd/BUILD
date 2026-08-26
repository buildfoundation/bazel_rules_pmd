load("//pmd:toolchain.bzl", "pmd_toolchain")

config_setting(
    name = "manifest_only_runfiles",
    values = {"enable_runfiles": "false"},
)

filegroup(
    name = "empty_wrapper_runfiles_manifest",
    srcs = [],
)

alias(
    name = "wrapper_runfiles_manifest",
    actual = select({
        ":manifest_only_runfiles": "//pmd/wrapper:bin",
        "//conditions:default": ":empty_wrapper_runfiles_manifest",
    }),
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
    "defs.bzl",
    "BUILD.pmd.bazel",
    "execution_result.sh.tpl",
])
