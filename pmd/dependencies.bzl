"""
Macros for defining dependencies.
See https://docs.bazel.build/versions/master/skylark/deploying.html#dependencies
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def rules_pmd_dependencies():
    """Fetches `rules_pmd` dependencies.

    Declares dependencies of the `rules_pmd` workspace.
    Users should call this macro in their `WORKSPACE` file.
    """

    # Java

    rules_java_version = "0.1.1"
    rules_java_sha = "220b87d8cfabd22d1c6d8e3cdb4249abd4c93dcc152e0667db061fb1b957ee68"

    maybe(
        repo_rule = http_archive,
        name = "rules_java",
        url = "https://github.com/bazelbuild/rules_java/releases/download/{v}/rules_java-{v}.tar.gz".format(v = rules_java_version),
        sha256 = rules_java_sha,
    )

    # JVM External

    rules_jvm_external_version = "3.2"
    rules_jvm_external_sha = "19d402ef15f58750352a1a38b694191209ebc7f0252104b81196124fdd43ffa0"

    maybe(
        repo_rule = http_archive,
        name = "rules_jvm_external",
        url = "https://github.com/bazelbuild/rules_jvm_external/archive/{v}.tar.gz".format(v = rules_jvm_external_version),
        strip_prefix = "rules_jvm_external-{v}".format(v = rules_jvm_external_version),
        sha256 = rules_jvm_external_sha,
    )
