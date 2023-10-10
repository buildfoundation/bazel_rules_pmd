"""
Macros for defining dependencies.
See https://docs.bazel.build/versions/master/skylark/deploying.html#dependencies
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load(":versions.bzl", _DEFAULT_PMD_VERSION = "DEFAULT_PMD_RELEASE")

_PMD_BUILD_FILE_TEMPLATE = Label("//pmd:BUILD.pmd.bazel")

def rules_pmd_dependencies(pmd_release = _DEFAULT_PMD_VERSION):
    """Fetches `rules_pmd` dependencies.

    Declares dependencies of the `rules_pmd` workspace.
    Users should call this macro in their `WORKSPACE` file.

    Args:
        pmd_release: The `pmd_release` target to fetch download.
    """

    # Java

    rules_java_version = "6.5.1"
    rules_java_sha = "7b0d9ba216c821ee8697dedc0f9d0a705959ace462a3885fe9ba0347ba950111"

    maybe(
        repo_rule = http_archive,
        name = "rules_java",
        url = "https://github.com/bazelbuild/rules_java/releases/download/{v}/rules_java-{v}.tar.gz".format(v = rules_java_version),
        sha256 = rules_java_sha,
    )

    _rules_pmd_bzlmod_dependencies(pmd_release = pmd_release)

def _rules_pmd_bzlmod_dependencies(pmd_release):
    if not pmd_release:
        fail("Error: Please provide `pmd_release` when calling rules_pmd_dependencies")

    maybe(
        repo_rule = http_archive,
        name = "net_sourceforge_pmd",
        url = "https://github.com/pmd/pmd/releases/download/pmd_releases/{v}/pmd-bin-{v}.zip".format(v = pmd_release.version),
        strip_prefix = "pmd-bin-{v}/lib".format(v = pmd_release.version),
        sha256 = pmd_release.sha256,
        build_file = _PMD_BUILD_FILE_TEMPLATE,
    )
