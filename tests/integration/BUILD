load("//pmd:defs.bzl", "pmd_test")

pmd_test(
    name = "pmd_error_test",
    srcs = glob(["src/main/java/**/*.java"]),
    report_format = "text",
    rulesets = ["pmd_rulesets_error.xml"],
    tags = ["manual"],
)

pmd_test(
    name = "pmd_errorless_test",
    srcs = glob(["src/main/java/**/*.java"]),
    report_format = "text",
    rulesets = ["pmd_rulesets_errorless.xml"],
    tags = ["manual"],
)
