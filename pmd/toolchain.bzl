"""
Toolchain declaration.
"""

def _impl(ctx):
    return [platform_common.ToolchainInfo(jvm_flags = ctx.attr.jvm_flags)]

pmd_toolchain = rule(
    implementation = _impl,
    attrs = {
        "jvm_flags": attr.string_list(
            default = [],
            doc = "JVM flags used for PMD execution.",
        ),
    },
)
