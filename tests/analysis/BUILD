load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("//pmd:config.bzl", "pmd_config")
load("//pmd:toolchain.bzl", "pmd_toolchain")
load(":tests.bzl", "test_suite")

pmd_toolchain(
    name = "custom_toolchain_impl",
    default_config = ":registered_config",
    pmd_wrapper = ":custom_wrapper_bin",
)

pmd_config(
    name = "registered_config",
    fail_on_violation = False,
    rules_minimum_priority = 4,
    rulesets = ["registered_rulesets.xml"],
    threads_count = 17,
)

write_file(
    name = "custom_wrapper_bin",
    out = "custom_pmd_wrapper",
    content = [
        "#!/bin/sh",
        "exit 0",
    ],
    is_executable = True,
)

write_file(
    name = "generated_ruleset",
    out = "generated_ruleset.xml",
    content = ["<ruleset name=\"generated\"/>"],
)

filegroup(
    name = "empty_rulesets",
    srcs = [],
)

config_setting(
    name = "select_config_b",
    values = {"compilation_mode": "opt"},
)

pmd_config(
    name = "config_a",
    rules_minimum_priority = 1,
    rulesets = ["rulesets_a.xml"],
    threads_count = 3,
)

pmd_config(
    name = "config_b",
    fail_on_violation = False,
    rules_minimum_priority = 2,
    rulesets = [":generated_ruleset"],
    threads_count = 7,
)

pmd_config(
    name = "empty_config",
    rulesets = [":empty_rulesets"],
)

toolchain(
    name = "custom_toolchain",
    toolchain = ":custom_toolchain_impl",
    toolchain_type = "//pmd:toolchain_type",
)

test_suite(
    name = "tests",
)
