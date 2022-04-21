"""
Macros for defining dependencies.
See https://docs.bazel.build/versions/master/skylark/deploying.html#dependencies
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def pmd_version(version, sha256):
    return struct(
        version = version,
        sha256 = sha256,
    )

_DEFAULT_PMD_RELEASE = pmd_version(
    version = "6.44.0",
    sha256 = "7e6dceba88529a90b2b33c8f05b53bc409fa9eab79be592c875f6bd996aaade7",
)

def rules_pmd_dependencies(pmd_release = _DEFAULT_PMD_RELEASE):
    """Fetches `rules_pmd` dependencies.

    Declares dependencies of the `rules_pmd` workspace.
    Users should call this macro in their `WORKSPACE` file.

    Args:
        pmd_release: Versioning information for the PMD release to use
    """

    # Java

    rules_java_version = "5.0.0"
    rules_java_sha = "ddc9e11f4836265fea905d2845ac1d04ebad12a255f791ef7fd648d1d2215a5b"

    maybe(
        repo_rule = http_archive,
        name = "rules_java",
        url = "https://github.com/bazelbuild/rules_java/archive/refs/tags/{v}.tar.gz".format(v = rules_java_version),
        strip_prefix = "rules_java-{v}".format(v = rules_java_version),
        sha256 = rules_java_sha,
    )

    maybe(
        repo_rule = http_archive,
        name = "rules_pmd_dependencies",
        url = "https://github.com/pmd/pmd/releases/download/pmd_releases/{v}/pmd-bin-{v}.zip".format(v = pmd_release.version),
        strip_prefix = "pmd-bin-{v}".format(v = pmd_release.version),
        sha256 = pmd_release.sha256,
        build_file_content = """
load("@rules_java//java:defs.bzl", "java_import")

java_import(
    name = "net_sourceforge_pmd",
    jars = glob(["lib/*.jar"]),
    visibility = ["//visibility:public"],
)
        """,
    )
