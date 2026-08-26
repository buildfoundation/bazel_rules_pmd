"""PMD release definitions."""

_DEFAULT_URL_TEMPLATES = [
    "https://github.com/pmd/pmd/releases/download/pmd_releases/{version}/pmd-dist-{version}-bin.zip",
]

def pmd_version(version, sha256, url_templates = None):
    """Create a pmd version.

    Args:
        version (str): The version of pmd.
        sha256 (str): The sha256 of the PMD distribution archive.
        url_templates (list, optional): URL templates for downloading PMD. Each template
            may contain `{version}` which will be replaced with the version string.
            Defaults to the standard GitHub release URL.

    Returns: A struct containing the version information.
    """
    return struct(
        version = version,
        sha256 = sha256,
        url_templates = url_templates if url_templates != None else _DEFAULT_URL_TEMPLATES,
    )

DEFAULT_PMD_RELEASE = pmd_version(
    version = "7.26.0",
    sha256 = "9f55cb7ff0e9f9a66dd2f005eaa370e84c8a4cd971b134aa14a930c4a283ebc9",
)
