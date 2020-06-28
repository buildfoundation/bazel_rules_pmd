"""
PMD rule source code.
"""

def _impl(ctx):
    inputs = []
    outputs = []

    arguments = ctx.actions.args()

    # Arguments are passed in a file. The file path is a special @-named argument.
    # See https://docs.oracle.com/javase/8/docs/technotes/tools/windows/javac.html#BHCJEIBB
    # A worker execution replaces the @-argument with the "--persistent_worker" one.
    # A non-worker execution preserves the argument which is eventually expanded to regular arguments.

    arguments.set_param_file_format("multiline")
    arguments.use_param_file("@%s", use_always = True)

    # Sources

    if len(ctx.files.srcs) != 0:
        srcs_file = _write_files_list(ctx, ctx.files.srcs, "srcs.txt")

        arguments.add("-filelist", srcs_file)

        inputs.append(srcs_file)
        inputs.extend(ctx.files.srcs)

    if len(ctx.files.srcs_ignore) != 0:
        srcs_file = _write_files_list(ctx, ctx.files.srcs_ignore, "srcs_ignore.txt")

        arguments.add("-ignorelist", srcs_file)

        inputs.append(srcs_file)
        inputs.extend(ctx.files.srcs_ignore)

    # Language

    arguments.add("-language", ctx.attr.language)

    if len(ctx.attr.language_version) != 0:
        arguments.add("-version", ctx.attr.language_version)

    # Rules

    arguments.add_joined("-rulesets", ctx.files.rulesets, join_with = ",")
    inputs.extend(ctx.files.rulesets)

    # Report

    report_file = ctx.actions.declare_file("{name}_pmd_report.{extension}".format(
        name = ctx.label.name,
        extension = _report_format_extensions.get(ctx.attr.report_format, default = ctx.attr.report_format),
    ))

    arguments.add("-format", ctx.attr.report_format)
    arguments.add("-reportfile", report_file)

    outputs.append(report_file)

    # Remaining options

    arguments.add("-failOnViolation", ctx.attr.fail_on_violation)
    arguments.add("-no-cache")
    arguments.add("-threads", ctx.attr.threads_count)

    # Run

    ctx.actions.run(
        mnemonic = "PMD",
        arguments = [arguments],
        executable = ctx.executable._executable,
        execution_requirements = {
            "supports-workers": "1",
            "supports-multiplex-workers": "0",
        },
        inputs = inputs,
        outputs = outputs,
    )

    return [DefaultInfo(files = depset(outputs))]

def _write_files_list(ctx, files, file_name):
    file = ctx.actions.declare_file(file_name)
    file_content = ",".join([src.path for src in files])

    ctx.actions.write(file, file_content, is_executable = False)

    return file

_report_format_extensions = {
    "codeclimate": "json",
    "summaryhtml": "html",
    "text": "txt",
}

pmd = rule(
    implementation = _impl,
    attrs = {
        "_executable": attr.label(
            default = "//pmd/wrapper:bin",
            executable = True,
            cfg = "host",
        ),
        "srcs": attr.label_list(
            allow_files = True,
            doc = "Source code files.",
            mandatory = True,
            allow_empty = False,
        ),
        "srcs_ignore": attr.label_list(
            allow_files = True,
            default = [],
            doc = "Source code files to ignore.",
        ),
        "language": attr.string(
            default = "java",
            values = ["ecmascript", "java"],
            doc = "See [PMD `-language` option](https://pmd.github.io/latest/pmd_userdocs_cli_reference.html)",
        ),
        "language_version": attr.string(
            doc = "See [PMD `-version` option](https://pmd.github.io/latest/pmd_userdocs_cli_reference.html)",
        ),
        "rulesets": attr.label_list(
            allow_files = True,
            mandatory = True,
            allow_empty = False,
            doc = "Ruleset files.",
        ),
        "report_format": attr.string(
            default = "text",
            values = ["codeclimate", "csv", "html", "summaryhtml", "text", "xml"],
            doc = "See [PMD `-format` option](https://pmd.github.io/latest/pmd_userdocs_cli_reference.html)",
        ),
        "fail_on_violation": attr.bool(
            default = True,
            doc = "See [PMD `-failOnViolation` option](https://pmd.github.io/latest/pmd_userdocs_cli_reference.html)",
        ),
        "threads_count": attr.int(
            default = 1,
            doc = "See [PMD `-threads` option](https://pmd.github.io/latest/pmd_userdocs_cli_reference.html)",
        ),
    },
    provides = [DefaultInfo],
)
