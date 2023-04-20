load("@rules_pmd//pmd:defs.bzl", "pmd_test_target")

pmd_test_target(
    name = "pmd_error",
    srcs = glob(["src/main/java/**/*.java"]),
    report_format = "text",
    rulesets = ["pmd_rulesets_error.xml"],
)

pmd_test_target(
    name = "pmd_errorless",
    srcs = glob(["src/main/java/**/*.java"]),
    report_format = "text",
    rulesets = ["pmd_rulesets_errorless.xml"],
)
