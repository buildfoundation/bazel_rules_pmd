load("@rules_java//java:defs.bzl", "java_binary", "java_library")
load("//pmd:config.bzl", "pmd_config")
load("//pmd:defs.bzl", "pmd_test")

java_library(
    name = "wrapper",
    srcs = glob(["src/main/java/**/*.java"]),
    deps = ["@net_sourceforge_pmd//:pmd"],
)

java_binary(
    name = "bin",
    main_class = "io.buildfoundation.bazel.pmd.Main",
    visibility = ["//visibility:public"],
    runtime_deps = [":wrapper"],
)

pmd_config(
    name = "pmd_test_config",
    rulesets = ["pmd_ruleset.xml"],
)

pmd_test(
    name = "pmd_test",
    srcs = glob(["src/main/java/**/*.java"]),
    config = ":pmd_test_config",
)
