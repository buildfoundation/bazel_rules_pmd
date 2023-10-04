load(
    "@bazel_tools//tools/build_defs/repo:http.bzl",
    "http_archive",
)
load(
    ":versions.bzl",
    _DEFAULT_PMD_RELEASE = "DEFAULT_PMD_RELEASE",
    _pmd_version = "pmd_version",
)

_version_tag = tag_class(
    attrs = {
        "version": attr.string(mandatory = True),
        "sha256": attr.string(mandatory = True),
    },
)

def _download_pmd_cli_all(pmd):
    http_archive(
        name = "net_sourceforge_pmd",
        urls = [url.format(version = pmd.version) for url in pmd.url_templates],
        strip_prefix = "pmd-bin-{v}/lib".format(v = pmd.version),
        sha256 = pmd.sha256,
        build_file = "//pmd:BUILD.pmd.bazel",
    )

def _pmd_impl(mctx):
    pmd_version = None
    for mod in mctx.modules:
        for override in mod.tags.pmd_version:
            if pmd_version:
                fail("Only a single pmd_version at once is supported right now!")
            pmd_version = _pmd_version(version = override.version, sha256 = override.sha256)

    kwargs = dict(pmd = _DEFAULT_PMD_RELEASE)
    if pmd_version:
        kwargs["pmd"] = pmd_version
    _download_pmd_cli_all(**kwargs)

pmd = module_extension(
    _pmd_impl,
    tag_classes = {"pmd_version": _version_tag},
)
