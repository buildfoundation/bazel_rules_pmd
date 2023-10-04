def pmd_version(version, sha256):
    """Create a pmd version.

    Args:
        version (str): The version of pmd.
        sha256 (str): The sha256 of the pmd jar.

    Returns: A struct containing the version information.
    """
    return struct(
        version = version,
        sha256 = sha256,
        url_templates = [
            "https://github.com/pmd/pmd/releases/download/pmd_releases/{version}/pmd-bin-{version}.zip",
        ],
    )

DEFAULT_PMD_RELEASE = pmd_version(
    version = "6.50.0",
    sha256 = "ccd2dccebaa5529fb0f95216fc70b6e959ddf1c61aa5a392d737e38b9f254e24",
)
