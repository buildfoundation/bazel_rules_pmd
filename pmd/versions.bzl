def version(version, sha256):
    """Defines a PMD release

    Args:
        version (str): The version of the release
        sha256 (str): The sha256 checksum of the release

    Returns: A struct containing the version and sha256 checksum of the release
    """
    return struct(version = version, sha256 = sha256)

PMD_RELEASE = version(
    version = "6.55.0",
    sha256 = "21acf96d43cb40d591cacccc1c20a66fc796eaddf69ea61812594447bac7a11d",
)
