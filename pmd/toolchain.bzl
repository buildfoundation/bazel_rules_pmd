"""
Toolchain declaration.
"""

def _impl(ctx):
    return [platform_common.ToolchainInfo(
        pmd_wrapper = ctx.attr.pmd_wrapper[DefaultInfo].files_to_run,
    )]

pmd_toolchain = rule(
    implementation = _impl,
    attrs = {
        "pmd_wrapper": attr.label(
            default = Label("//pmd/wrapper:bin"),
            executable = True,
            cfg = "exec",
            doc = "Executable wrapper used to run PMD.",
        ),
    },
)
