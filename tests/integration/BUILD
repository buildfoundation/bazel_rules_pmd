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
    name = "pmd_error_ignored",
    srcs = ["src/main/java/A.java"],
    report_format = "text",
    rulesets = ["pmd_rulesets_error.xml"],
    srcs_ignore = ["src/main/java/A.java"],
    tags = ["manual"],
)

sh_test(
    name = "pmd_error_ignored_test",
    srcs = ["test_pmd.sh"],
    args = [
        "0",
        "$(rootpath :pmd_error_ignored)",
    ],
    data = [":pmd_error_ignored"],
)

pmd_test(
    name = "pmd_error_mixed_ignored",
    srcs = [
        "src/main/java/A.java",
        "src/main/java/B.java",
    ],
    report_format = "text",
    rulesets = ["pmd_rulesets_error.xml"],
    srcs_ignore = ["src/main/java/A.java"],
    tags = ["manual"],
)

sh_test(
    name = "pmd_error_mixed_ignored_test",
    srcs = ["test_pmd.sh"],
    args = [
        "4",
        "$(rootpath :pmd_error_mixed_ignored)",
    ],
    data = [":pmd_error_mixed_ignored"],
)

pmd_test(
    name = "pmd_errorless",
    srcs = glob(["src/main/java/**/*.java"]),
    report_format = "text",
    rulesets = ["pmd_rulesets_errorless.xml"],
    srcs_language_version = "1.8",
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

pmd_test(
    name = "pmd_error_no_fail",
    srcs = glob(["src/main/java/**/*.java"]),
    fail_on_violation = False,
    report_format = "text",
    rulesets = ["pmd_rulesets_error.xml"],
    tags = ["manual"],
)

sh_test(
    name = "pmd_error_no_fail_test",
    srcs = ["test_pmd.sh"],
    args = [
        "0",
        "$(rootpath :pmd_error_no_fail)",
    ],
    data = [":pmd_error_no_fail"],
)

pmd_test(
    name = "pmd_error_textcolor",
    srcs = glob(["src/main/java/**/*.java"]),
    report_format = "textcolor",
    rulesets = ["pmd_rulesets_error.xml"],
    tags = ["manual"],
)

sh_test(
    name = "pmd_error_textcolor_test",
    srcs = ["test_pmd.sh"],
    args = [
        "4",
        "$(rootpath :pmd_error_textcolor)",
        "textcolor",
    ],
    data = [":pmd_error_textcolor"],
)

pmd_test(
    name = "pmd_error_textpad",
    srcs = glob(["src/main/java/**/*.java"]),
    report_format = "textpad",
    rulesets = ["pmd_rulesets_error.xml"],
    tags = ["manual"],
)

sh_test(
    name = "pmd_error_textpad_test",
    srcs = ["test_pmd.sh"],
    args = [
        "4",
        "$(rootpath :pmd_error_textpad)",
        "textpad",
    ],
    data = [":pmd_error_textpad"],
)

pmd_test(
    name = "pmd_error_sarif",
    srcs = glob(["src/main/java/**/*.java"]),
    report_format = "sarif",
    rulesets = ["pmd_rulesets_error.xml"],
    tags = ["manual"],
)

sh_test(
    name = "pmd_error_sarif_test",
    srcs = ["test_pmd.sh"],
    args = [
        "4",
        "$(rootpath :pmd_error_sarif)",
        "sarif",
    ],
    data = [":pmd_error_sarif"],
)

pmd_test(
    name = "pmd_error_xml",
    srcs = glob(["src/main/java/**/*.java"]),
    report_format = "xml",
    rulesets = ["pmd_rulesets_error.xml"],
    tags = ["manual"],
)

sh_test(
    name = "pmd_error_xml_test",
    srcs = ["test_pmd.sh"],
    args = [
        "4",
        "$(rootpath :pmd_error_xml)",
        "xml",
    ],
    data = [":pmd_error_xml"],
)

sh_test(
    name = "pmd_wrapper_arguments_test",
    srcs = ["test_wrapper.sh"],
    args = [
        "$(rootpath //pmd/wrapper:bin)",
        "$(rootpath src/main/java/A.java)",
        "$(rootpath pmd_rulesets_error.xml)",
    ],
    data = [
        "pmd_rulesets_error.xml",
        "src/main/java/A.java",
        "//pmd/wrapper:bin",
    ],
)
