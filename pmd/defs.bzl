"""
PMD build and test rules.
"""

load(":config.bzl", "PmdConfigInfo")

TOOLCHAIN_TYPE = Label("//pmd:toolchain_type")
_SH_TOOLCHAIN_TYPE = Label("@rules_shell//shell:toolchain_type")

_LANGUAGE_ALIASES = {
    "vf": "visualforce",
    "vm": "velocity",
}

def _impl(ctx, is_test):
    inputs = []
    source_lists = []
    outputs = []
    pmd_toolchain = ctx.toolchains[TOOLCHAIN_TYPE]
    if ctx.attr.config != None:
        config = ctx.attr.config[PmdConfigInfo]
        config_label = ctx.attr.config.label
    else:
        config = pmd_toolchain.default_config
        config_label = pmd_toolchain.default_config_label

    arguments = ctx.actions.args()
    arguments.add("check")

    # Sources

    if len(ctx.files.srcs) != 0:
        srcs_file = _write_files_list(ctx, ctx.files.srcs, "srcs_{}.txt".format(ctx.label.name))
        arguments.add("--file-list", srcs_file)

        source_lists.append(srcs_file)
        inputs.append(srcs_file)
        inputs.extend(ctx.files.srcs)

    if len(ctx.files.srcs_ignore) != 0:
        srcs_ignore_file = _write_files_list(ctx, ctx.files.srcs_ignore, "srcs_ignore_{}.txt".format(ctx.label.name))
        arguments.add("--exclude-file-list", srcs_ignore_file)

        source_lists.append(srcs_ignore_file)
        inputs.append(srcs_ignore_file)
        inputs.extend(ctx.files.srcs_ignore)

    arguments.add("--encoding", ctx.attr.srcs_encoding)

    # Language

    language = _LANGUAGE_ALIASES.get(ctx.attr.srcs_language, ctx.attr.srcs_language)
    arguments.add("--force-language", language)

    if len(ctx.attr.srcs_language_version) != 0:
        arguments.add("--use-version", "{}-{}".format(language, ctx.attr.srcs_language_version))

    # Rules

    if len(config.rulesets) == 0:
        fail("PMD configuration {} selected by {} has no ruleset files; set config or the registered toolchain's default_config to a populated pmd_config".format(config_label, ctx.label))

    arguments.add_joined("--rulesets", config.rulesets, join_with = ",")
    inputs.extend(config.rulesets)

    arguments.add("--minimum-priority", config.rules_minimum_priority)

    # Report

    report_file = ctx.actions.declare_file("{name}_pmd_report.{extension}".format(
        name = ctx.label.name,
        extension = _report_format_extensions.get(ctx.attr.report_format, default = ctx.attr.report_format),
    ))

    arguments.add("--format", ctx.attr.report_format)
    arguments.add("--report-file", report_file)

    outputs.append(report_file)

    # Remaining options

    if not ctx.attr.fail_on_violation:
        arguments.add("--no-fail-on-violation")
    arguments.add("--no-cache")
    arguments.add("--no-progress")
    arguments.add("--threads", config.threads_count)

    execution_result = None
    pmd_result = None
    if is_test:
        # Execution-result config
        # inspired by https://github.com/bazelbuild/bazel-skylib/blob/a360c42f3d7c7697c8521ed831ebf94ff4120451/rules/build_test.bzl#L21
        execution_result = ctx.actions.declare_file("{}_execution_result.sh".format(ctx.label.name))
        pmd_result = ctx.actions.declare_file("{}_pmd_result.txt".format(ctx.label.name))
        outputs.append(pmd_result)
        arguments.add("--execution-result", "{}".format(pmd_result.path))

    # Run

    stage_args = ctx.actions.args()
    stage_args.add(pmd_toolchain.pmd_wrapper.executable)
    stage_args.add_all(source_lists)
    stage_args.add("--")
    stage_args.add_all(source_lists + config.rulesets + outputs)
    stage_args.add("--")

    # run_shell resolves Bash on every platform; Windows cannot exec a .sh directly.
    ctx.actions.run_shell(
        mnemonic = "PMD",
        command = '"{}" "$@"'.format(ctx.file._runner.path),
        tools = [pmd_toolchain.pmd_wrapper, ctx.file._runner],
        inputs = inputs,
        outputs = outputs,
        arguments = [stage_args, arguments],
        toolchain = TOOLCHAIN_TYPE,
    )

    if not is_test:
        return [DefaultInfo(files = depset([report_file]))]

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

    runfiles = ctx.runfiles(files = [report_file, pmd_result, execution_result])
    runfiles = runfiles.merge(ctx.attr._runfiles[DefaultInfo].default_runfiles)

    files = [report_file, execution_result]
    executable = execution_result
    if ctx.target_platform_has_constraint(ctx.attr._windows_constraint[platform_common.ConstraintValueInfo]):
        executable = _windows_bash_launcher(ctx, execution_result)
        files.append(executable)

    return [
        DefaultInfo(
            files = depset(files),
            executable = executable,
            runfiles = runfiles,
        ),
    ]

def _windows_bash_launcher(ctx, script):
    # Mirrors rules_shell's sh_test launcher: Windows tests must be .exe files.
    sh = ctx.toolchains[_SH_TOOLCHAIN_TYPE]
    if not sh or not sh.path or not sh.launcher or not sh.launcher_maker:
        fail("pmd_test on Windows needs Bash; set BAZEL_SH to the path of bash.exe")

    launcher = ctx.actions.declare_file(ctx.label.name + ".exe")
    launch_info = ctx.actions.args().use_param_file("%s", use_always = True).set_param_file_format("multiline")
    launch_info.add("binary_type=Bash")
    launch_info.add(ctx.workspace_name, format = "workspace_name=%s")
    launch_info.add("1" if ctx.configuration.runfiles_enabled() else "0", format = "symlink_runfiles_enabled=%s")
    launch_info.add(sh.path, format = "bash_bin_path=%s")
    launch_info.add(_runfile_path(ctx, script), format = "bash_file_rlocationpath=%s")

    ctx.actions.run(
        executable = sh.launcher_maker,
        inputs = [sh.launcher],
        outputs = [launcher],
        arguments = [sh.launcher.path, launch_info, launcher.path],
        mnemonic = "PmdTestLauncher",
        toolchain = _SH_TOOLCHAIN_TYPE,
    )
    return launcher

def _write_files_list(ctx, files, file_name):
    file = ctx.actions.declare_file(file_name)
    file_content = "\n".join([src.path for src in files])

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
    "sarif": "sarif",
    "summaryhtml": "html",
    "text": "txt",
    "xml": "xml",
}

_text_report_formats = ["text", "textcolor", "textpad"]

_ATTRS = {
    "_runner": attr.label(
        default = "//pmd:run_pmd.sh",
        allow_single_file = True,
    ),
    "_execution_result_template": attr.label(
        allow_single_file = True,
        default = "//pmd:execution_result.sh.tpl",
    ),
    "_runfiles": attr.label(
        default = "@rules_shell//shell/runfiles",
    ),
    "_windows_constraint": attr.label(
        default = "@platforms//os:windows",
        providers = [platform_common.ConstraintValueInfo],
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
        doc = "See [PMD `--encoding` option](https://docs.pmd-code.org/latest/pmd_userdocs_cli_reference.html)",
    ),
    "srcs_language": attr.string(
        default = "java",
        values = ["apex", "ecmascript", "java", "jsp", "modelica", "plsql", "scala", "vf", "vm", "xml"],
        doc = "See [PMD `--force-language` option](https://docs.pmd-code.org/latest/pmd_userdocs_cli_reference.html)",
    ),
    "srcs_language_version": attr.string(
        doc = "PMD language version (for example, `1.8` for Java); see [PMD `--use-version` option](https://docs.pmd-code.org/latest/pmd_userdocs_cli_reference.html)",
    ),
    "report_format": attr.string(
        default = "text",
        values = ["codeclimate", "csv", "json", "html", "sarif", "summaryhtml", "text", "textcolor", "textpad", "xml"],
        doc = "See [PMD `--format` option](https://docs.pmd-code.org/latest/pmd_userdocs_cli_reference.html)",
    ),
    "config": attr.label(
        providers = [PmdConfigInfo],
        doc = "PMD configuration. Replaces the registered toolchain's default_config completely when provided.",
    ),
    "fail_on_violation": attr.bool(
        default = True,
        doc = "See [PMD `--fail-on-violation` option](https://docs.pmd-code.org/latest/pmd_userdocs_cli_reference.html)",
    ),
}

def _pmd_impl(ctx):
    return _impl(ctx, is_test = False)

pmd = rule(
    implementation = _pmd_impl,
    attrs = _ATTRS,
    provides = [DefaultInfo],
    toolchains = [TOOLCHAIN_TYPE],
)

def _pmd_test_impl(ctx):
    return _impl(ctx, is_test = True)

pmd_test = rule(
    implementation = _pmd_test_impl,
    attrs = _ATTRS,
    provides = [DefaultInfo],
    toolchains = [
        TOOLCHAIN_TYPE,
        config_common.toolchain_type(_SH_TOOLCHAIN_TYPE, mandatory = False),
    ],
    test = True,
)
