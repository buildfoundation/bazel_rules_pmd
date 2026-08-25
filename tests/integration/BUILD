load("@rules_shell//shell:sh_test.bzl", "sh_test")
load("//pmd:defs.bzl", "pmd_test")

pmd_test(
    name = "pmd_error",
    srcs = glob(["src/main/java/**/*.java"]),
    report_format = "text",
    rulesets = ["pmd_rulesets_error.xml"],
    tags = ["manual"],
)

sh_test(
    name = "pmd_error_test",
    srcs = ["test_pmd.sh"],
    args = [
        "4",
        "$(rootpath :pmd_error)",
    ],
    data = [":pmd_error"],
)

pmd_test(
    name = "pmd_errorless",
    srcs = glob(["src/main/java/**/*.java"]),
    report_format = "text",
    rulesets = ["pmd_rulesets_errorless.xml"],
    tags = ["manual"],
)

sh_test(
    name = "pmd_errorless_test",
    srcs = ["test_pmd.sh"],
    args = [
        "0",
        "$(rootpath :pmd_errorless)",
    ],
    data = [":pmd_errorless"],
)
