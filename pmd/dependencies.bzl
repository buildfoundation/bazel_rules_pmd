"""
Dependencies required by PMD
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

PMD_RELEASE = {
    "urls": [
        "https://github.com/pmd/pmd/releases/download/pmd_releases/6.31.0/pmd-bin-6.31.0.zip",
    ],
    "sha256": "ec9e81569fdde3ed52f504ff29d9f535560852435d3c467b605fb8d7728a0189",
}

def rules_pmd_dependencies(pmd_release = PMD_RELEASE):
    """Fetches the dependencies for rules_pmd

    Args:
        pmd_release: The PMD release to use
    """
    # The PMD jars

    http_archive(
        name = "pmd",
        urls = pmd_release["urls"],
        sha256 = pmd_release["sha256"],
        build_file = "@rules_pmd//pmd/internal:BUILD.pmd",
    )

    # Java Rules

    RULES_JAVA = "5.0.0"
    RULES_JAVA_SHA = "ddc9e11f4836265fea905d2845ac1d04ebad12a255f791ef7fd648d1d2215a5b"

    maybe(
        repo_rule = http_archive,
        name = "rules_java",
        url = "https://github.com/bazelbuild/rules_java/archive/{}.tar.gz".format(RULES_JAVA),
        strip_prefix = "rules_java-{}".format(RULES_JAVA),
        sha256 = RULES_JAVA_SHA,
    )

    # JVM External

    RULES_JVM_EXTERNAL = "4.2"
    RULES_JVM_EXTERNAL_SHA = "cd1a77b7b02e8e008439ca76fd34f5b07aecb8c752961f9640dea15e9e5ba1ca"

    maybe(
        repo_rule = http_archive,
        name = "rules_jvm_external",
        url = "https://github.com/bazelbuild/rules_jvm_external/archive/{}.tar.gz".format(RULES_JVM_EXTERNAL),
        strip_prefix = "rules_jvm_external-{}".format(RULES_JVM_EXTERNAL),
        sha256 = RULES_JVM_EXTERNAL_SHA,
    )
