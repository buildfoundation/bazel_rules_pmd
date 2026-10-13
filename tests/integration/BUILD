load("@bazel_skylib//rules:diff_test.bzl", "diff_test")
load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("@rules_shell//shell:sh_test.bzl", "sh_test")
load("//pmd:config.bzl", "pmd_config")
load("//pmd:defs.bzl", "pmd", "pmd_test")

pmd_config(
    name = "pmd_error_config",
    rulesets = ["pmd_rulesets_error.xml"],
)

pmd_config(
    name = "pmd_errorless_config",
    rulesets = ["pmd_rulesets_errorless.xml"],
)

pmd_config(
    name = "pmd_error_no_fail_config",
    fail_on_violation = False,
    rulesets = ["pmd_rulesets_error.xml"],
)

pmd(
    name = "pmd_build_clean",
    srcs = ["src/main/java/A.java"],
    config = ":pmd_errorless_config",
    report_format = "text",
    srcs_language_version = "1.8",
)

pmd(
    name = "pmd_build_no_fail",
    srcs = ["src/main/java/A.java"],
    config = ":pmd_error_no_fail_config",
    report_format = "text",
)

write_file(
    name = "pmd_build_clean_report_expected",
    out = "pmd_build_clean_report_expected.txt",
    content = [],
    newline = "unix",
)

diff_test(
    name = "pmd_build_clean_report_test",
    file1 = ":pmd_build_clean_report_expected",
    file2 = ":pmd_build_clean",
)

write_file(
    name = "pmd_build_no_fail_report_expected",
    out = "pmd_build_no_fail_report_expected.txt",
    content = [
        "tests/integration/src/main/java/A.java:1:\tAbstractClassWithoutAbstractMethod:\tThis abstract class does not have any abstract methods\n",
    ],
    newline = "unix",
)

diff_test(
    name = "pmd_build_no_fail_report_test",
    file1 = ":pmd_build_no_fail_report_expected",
    file2 = ":pmd_build_no_fail",
)

pmd(
    name = "pmd_error_build_failure",
    srcs = glob(["src/main/java/**/*.java"]),
    config = ":pmd_error_config",
    report_format = "text",
    tags = ["manual"],
)

pmd_test(
    name = "pmd_error",
    srcs = glob(["src/main/java/**/*.java"]),
    config = ":pmd_error_config",
    report_format = "text",
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
    config = ":pmd_error_config",
    report_format = "text",
    srcs_ignore = ["src/main/java/A.java"],
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
    config = ":pmd_error_config",
    report_format = "text",
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
    config = ":pmd_errorless_config",
    report_format = "text",
    srcs_language_version = "1.8",
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
    config = ":pmd_error_no_fail_config",
    report_format = "text",
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
    config = ":pmd_error_config",
    report_format = "textcolor",
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
    config = ":pmd_error_config",
    report_format = "textpad",
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
    config = ":pmd_error_config",
    report_format = "sarif",
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
    config = ":pmd_error_config",
    report_format = "xml",
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
