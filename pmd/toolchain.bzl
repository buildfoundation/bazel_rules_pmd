"""
Toolchain declaration.
"""

load(":config.bzl", "PmdConfigInfo")

def _impl(ctx):
    return [platform_common.ToolchainInfo(
        pmd_wrapper = ctx.attr.pmd_wrapper[DefaultInfo].files_to_run,
        default_config = ctx.attr.default_config[PmdConfigInfo],
    )]

pmd_toolchain = rule(
    implementation = _impl,
    attrs = {
        "default_config": attr.label(
            default = Label("//pmd:default_config"),
            providers = [PmdConfigInfo],
            doc = "Configuration used when a PMD target omits config.",
        ),
        "pmd_wrapper": attr.label(
            default = Label("//pmd/wrapper:bin"),
            executable = True,
            cfg = "exec",
            doc = "Executable wrapper used to run PMD.",
        ),
    },
)
