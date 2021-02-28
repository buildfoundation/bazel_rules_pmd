load("@rules_java//java:defs.bzl", "java_binary", "java_library")

java_library(
    name = "wrapper",
    srcs = glob(["src/main/java/**/*.java"]),
    deps = [
        "@rules_pmd_dependencies//:net_sourceforge_pmd_pmd_core",
        "@rules_pmd_dependencies//:net_sourceforge_pmd_pmd_dist",
    ],
)

java_binary(
    name = "bin",
    main_class = "io.buildfoundation.bazel.pmd.Main",
    visibility = ["//visibility:public"],
    runtime_deps = [":wrapper"],
)