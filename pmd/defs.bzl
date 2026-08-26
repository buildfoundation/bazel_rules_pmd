"""
PMD rule source code.
"""

TOOLCHAIN_TYPE = Label("//pmd:toolchain_type")

def _impl(ctx):
    inputs = []
    outputs = []

    java_arguments = ctx.actions.args()

    for jvm_flag in ctx.toolchains[TOOLCHAIN_TYPE].jvm_flags:
        # The Bazel-generated execution script requires "=" between argument names and values.
        java_arguments.add("--jvm_flag={}".format(jvm_flag))

    arguments = ctx.actions.args()

    # Sources

    if len(ctx.files.srcs) != 0:
        srcs_file = _write_files_list(ctx, ctx.files.srcs, "srcs_{}.txt".format(ctx.label.name))
        arguments.add("--file-list", srcs_file)

        inputs.append(srcs_file)
        inputs.extend(ctx.files.srcs)

    if len(ctx.files.srcs_ignore) != 0:
        srcs_ignore_file = _write_files_list(ctx, ctx.files.srcs_ignore, "srcs_ignore_{}.txt".format(ctx.label.name))
        arguments.add("--ignore-list", srcs_ignore_file)

        inputs.append(srcs_ignore_file)
        inputs.extend(ctx.files.srcs_ignore)

    arguments.add("--encoding", ctx.attr.srcs_encoding)

    # Language

    arguments.add("-language", ctx.attr.srcs_language)

    if len(ctx.attr.srcs_language_version) != 0:
        arguments.add("-version", ctx.attr.srcs_language_version)

    # Rules

    arguments.add_joined("--rulesets", ctx.files.rulesets, join_with = ",")
    inputs.extend(ctx.files.rulesets)

    arguments.add("--minimum-priority", ctx.attr.rules_minimum_priority)

    # Report

    report_file = ctx.actions.declare_file("{name}_pmd_report.{extension}".format(
        name = ctx.label.name,
        extension = _report_format_extensions.get(ctx.attr.report_format, default = ctx.attr.report_format),
    ))

    arguments.add("--format", ctx.attr.report_format)
    arguments.add("--report-file", report_file)

    outputs.append(report_file)

    # Remaining options

    arguments.add("--fail-on-violation", ctx.attr.fail_on_violation)
    arguments.add("--no-cache")
    arguments.add("--threads", ctx.attr.threads_count)

    # Execution-result config
    # inspired by https://github.com/bazelbuild/bazel-skylib/blob/a360c42f3d7c7697c8521ed831ebf94ff4120451/rules/build_test.bzl#L21
    execution_result = ctx.actions.declare_file("{}_execution_result.sh".format(ctx.label.name))
    pmd_result = ctx.actions.declare_file("{}_pmd_result.sh".format(ctx.label.name))
    outputs.append(pmd_result)
    arguments.add("--execution-result", "{}".format(pmd_result.path))

    # Run

    ctx.actions.run(
        mnemonic = "PMD",
        executable = ctx.executable._executable,
        inputs = inputs,
        outputs = outputs,
        arguments = [java_arguments, arguments],
    )

    report_runfile = _runfile_path(ctx, report_file)
    pmd_result_runfile = _runfile_path(ctx, pmd_result)
    ctx.actions.expand_template(
        template = ctx.file._execution_result_template,
        output = execution_result,
        substitutions = {
            "__PMD_REPORT__": _shell_quote(report_runfile) if ctx.attr.report_format in _text_report_formats else "''",
            "__PMD_RESULT__": _shell_quote(pmd_result_runfile),
        },
        is_executable = True,
    )

    runfiles = ctx.runfiles(files = [report_file, pmd_result])
    runfiles = runfiles.merge(ctx.attr._runfiles[DefaultInfo].default_runfiles)

    return [
        DefaultInfo(
            files = depset([report_file, execution_result]),
            executable = execution_result,
            runfiles = runfiles,
        ),
    ]

def _write_files_list(ctx, files, file_name):
    file = ctx.actions.declare_file(file_name)
    file_content = ",".join([src.path for src in files])

    ctx.actions.write(file, file_content, is_executable = False)

    return file

def _runfile_path(ctx, file):
    if file.short_path.startswith("../"):
        return file.short_path[3:]
    return "{}/{}".format(ctx.workspace_name, file.short_path)

def _shell_quote(value):
    return "'{}'".format(value.replace("'", "'\"'\"'"))

_report_format_extensions = {
    "codeclimate": "json",
    "csv": "csv",
    "html": "html",
    "json": "json",
    "summaryhtml": "html",
    "text": "txt",
    "xml": "xml",
}

_text_report_formats = ["text", "textcolor", "textpad"]

pmd_test = rule(
    implementation = _impl,
    attrs = {
        "_executable": attr.label(
            default = "//pmd/wrapper:bin",
            executable = True,
            cfg = "exec",
        ),
        "_execution_result_template": attr.label(
            allow_single_file = True,
            default = "//pmd:execution_result.sh.tpl",
        ),
        "_runfiles": attr.label(
            default = "@rules_shell//shell/runfiles",
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
        "srcs_encoding": attr.string(
            default = "UTF-8",
            doc = "See [PMD `-encoding` option](https://pmd.github.io/latest/pmd_userdocs_cli_reference.html)",
        ),
        "srcs_language": attr.string(
            default = "java",
            values = ["apex", "ecmascript", "java", "jsp", "modelica", "plsql", "scala", "vf", "vm", "xml"],
            doc = "See [PMD `-language` option](https://pmd.github.io/latest/pmd_userdocs_cli_reference.html)",
        ),
        "srcs_language_version": attr.string(
            doc = "See [PMD `-version` option](https://pmd.github.io/latest/pmd_userdocs_cli_reference.html)",
        ),
        "rulesets": attr.label_list(
            allow_files = True,
            mandatory = True,
            allow_empty = False,
            doc = "Ruleset files.",
        ),
        "rules_minimum_priority": attr.int(
            default = 5,
            doc = "See [PMD `-minimumpriority` option](https://pmd.github.io/latest/pmd_userdocs_cli_reference.html)",
        ),
        "report_format": attr.string(
            default = "text",
            values = ["codeclimate", "csv", "json", "html", "summaryhtml", "text", "textcolor", "textpad", "xml"],
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
    toolchains = [TOOLCHAIN_TYPE],
    test = True,
)
