load("@rules_pmd//pmd:defs.bzl", "pmd")

pmd(
    name = "sample",
    srcs = glob(["src/main/java/**/*.java"]),
    report_format = "html",
    rulesets = ["rulesets.xml"],
)
