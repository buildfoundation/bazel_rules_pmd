"""Definitions for bzlmod module extensions."""

load(":dependencies.bzl", "rules_pmd_dependencies")
load(":versions.bzl", "PMD_RELEASE", "version")

_pmd_release_tag = tag_class(
    attrs = {
        "version": attr.string(default = PMD_RELEASE.version),
        "sha256": attr.string(default = PMD_RELEASE.sha256),
    },
)

def _pmd_repository_extensions_impl(ctx):
    releases = []
    for mod in ctx.modules:
        for pmd_release in mod.tags.pmd_release:
            releases.append(version(version = pmd_release.version, sha256 = pmd_release.sha256))

    if len(releases) == 0:
        releases.append(PMD_RELEASE)
    elif len(releases) > 1:
        fail("Error: rules_pmd currently only supports a single pmd release at a time.")

    # TODO: Add support for multiple releases here
    release = releases[0]
    rules_pmd_dependencies(pmd_release = release)

pmd_repository_extensions = module_extension(
    implementation = _pmd_repository_extensions_impl,
    tag_classes = {
        "pmd_release": _pmd_release_tag,
    },
)
