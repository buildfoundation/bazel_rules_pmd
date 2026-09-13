load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load("@io_bazel_stardoc//stardoc:stardoc.bzl", "stardoc")

stardoc(
    name = "config_docs",
    out = "config.md",
    input = "//pmd:config.bzl",
    rule_template = "//docs:rule_template.vm",
)

stardoc(
    name = "docs",
    out = "rule.md",
    input = "//pmd:defs.bzl",
    rule_template = "//docs:rule_template.vm",
    deps = [":config_bzl"],
)

stardoc(
    name = "toolchain_docs",
    out = "toolchain.md",
    input = "//pmd:toolchain.bzl",
    rule_template = "//docs:rule_template.vm",
    deps = [":config_bzl"],
)

bzl_library(
    name = "config_bzl",
    srcs = ["//pmd:config.bzl"],
)
