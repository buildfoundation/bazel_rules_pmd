"""
Macros for defining toolchains.
See https://docs.bazel.build/versions/master/skylark/deploying.html#registering-toolchains
"""

load("@rules_java//java:repositories.bzl", "rules_java_dependencies", "rules_java_toolchains")
load("@rules_jvm_external//:defs.bzl", "maven_install")
load("@rules_jvm_external//:specs.bzl", "maven")

def rules_pmd_toolchains(pmd_version = "6.23.0"):
    """Invokes `rules_pmd` toolchains.

    Declares toolchains that are dependencies of the `rules_pmd` workspace.
    Users should call this macro in their `WORKSPACE` file.

    Args:
        pmd_version: "net.sourceforge.pmd:pmd-dist" version used by rules.
    """

    rules_java_dependencies()
    rules_java_toolchains()

    maven_install(
        name = "rules_pmd_dependencies",
        artifacts = [
            maven.artifact("net.sourceforge.pmd", "pmd-dist", pmd_version),
        ],
        repositories = [
            "https://repo1.maven.org/maven2",
            "https://repo.maven.apache.org/maven2/",
        ],
    )
