"""
Macros for defining toolchains.
See https://docs.bazel.build/versions/master/skylark/deploying.html#registering-toolchains
"""

load("@rules_java//java:repositories.bzl", "rules_java_dependencies", "rules_java_toolchains")

def rules_pmd_toolchains():
    """Invokes `rules_pmd` toolchains.

    Declares toolchains that are dependencies of the `rules_pmd` workspace.
    Users should call this macro in their `WORKSPACE` file.
    """

    rules_java_dependencies()
    rules_java_toolchains()
