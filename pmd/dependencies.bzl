"""
Macros for defining dependencies.
See https://docs.bazel.build/versions/master/skylark/deploying.html#dependencies
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load(":versions.bzl", "PMD_RELEASE")

def rules_pmd_dependencies(pmd_release = PMD_RELEASE):
    """Fetches `rules_pmd` dependencies.

    Declares dependencies of the `rules_pmd` workspace.
    Users should call this macro in their `WORKSPACE` file.

    Args:
        pmd_release: A `pmd_release` struct containing the version and sha256 of the
            PMD bin release associated with the Github release.
    """
    _rules_pmd_dependencies()
    _rules_pmd_bzlmod_dependencies(pmd_release = pmd_release)

def _rules_pmd_dependencies():
    """Fetches `rules_pmd` dependencies. This can be dropped once we deprecate WORKSPACE
    and switch fully to Bzlmod.
    """
    maybe(
        repo_rule = http_archive,
        name = "rules_java",
        url = "https://github.com/bazelbuild/rules_java/releases/download/6.0.0/rules_java-6.0.0.tar.gz",
        sha256 = "469b7f3b580b4fcf8112f4d6d0d5a4ce8e1ad5e21fee67d8e8335d5f8b3debab",
    )

def _rules_pmd_bzlmod_dependencies(pmd_release):
    """Fetches `rules_pmd` dependencies that are specific to Bzlmod.
    """
    if not pmd_release:
        fail("Error: Please provide `pmd_release` when calling rules_pmd_dependencies")
    maybe(
        repo_rule = http_archive,
        name = "net_sourceforge_pmd",
        url = "https://github.com/pmd/pmd/releases/download/pmd_releases/{v}/pmd-bin-{v}.zip".format(v = pmd_release.version),
        strip_prefix = "pmd-bin-{v}/lib".format(v = pmd_release.version),
        sha256 = pmd_release.sha256,
        build_file = "//pmd:BUILD.pmd.bazel",
    )
