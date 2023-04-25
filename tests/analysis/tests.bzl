"""
The rule analysis tests.
"""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("@rules_pmd//pmd:defs.bzl", "pmd_test")

def _expand_paths(ctx, values):
    source_dir = ctx.build_file_path.replace("/BUILD", "")
    output_dir = ctx.bin_dir.path

    return [
        value
            .replace("{{source_dir}}", source_dir)
            .replace("{{output_dir}}", output_dir)
        for value in values
    ]

# Action full contents test

def _action_full_contents_test_impl(ctx):
    env = analysistest.begin(ctx)

    actions = analysistest.target_actions(env)
    asserts.equals(env, 7, len(actions))

    # Action: writing file "srcs.txt"

    action_write_file_srcs = actions[0]

    action_write_file_srcs_outputs_expected = _expand_paths(env.ctx, [
        "{{output_dir}}/{{source_dir}}/srcs_test_target_full.txt",
    ])
    action_write_file_srcs_outputs_actual = [file.path for file in action_write_file_srcs.outputs.to_list()]

    asserts.equals(env, action_write_file_srcs_outputs_expected, action_write_file_srcs_outputs_actual)

    # Action: writing file "srcs_ignore.txt"

    action_write_file_srcs_ignore = actions[1]

    action_write_file_srcs_ignore_ouptuts_expected = _expand_paths(env.ctx, [
        "{{output_dir}}/{{source_dir}}/srcs_ignore_test_target_full.txt",
    ])
    action_write_file_srcs_ignore_ouptuts_actual = [file.path for file in action_write_file_srcs_ignore.outputs.to_list()]

    asserts.equals(env, action_write_file_srcs_ignore_ouptuts_expected, action_write_file_srcs_ignore_ouptuts_actual)

    # Action: PMD

    action_pmd = actions[2]

    action_pmd_arguments_expected = _expand_paths(env.ctx, [
        "bazel-out/host/bin/pmd/wrapper/bin",
        "--file-list",
        "{{output_dir}}/{{source_dir}}/srcs_test_target_full.txt",
        "--ignore-list",
        "{{output_dir}}/{{source_dir}}/srcs_ignore_test_target_full.txt",
        "--encoding",
        "UTF-8",
        "-language",
        "java",
        "-version",
        "1.8",
        "--rulesets",
        "{{source_dir}}/rulesets.xml",
        "--minimum-priority",
        "42",
        "--format",
        "html",
        "--report-file",
        "{{output_dir}}/{{source_dir}}/test_target_full_pmd_report.html",
        "--fail-on-violation",
        "false",
        "--no-cache",
        "--threads",
        "42",
        "--execution-result",
        "{{output_dir}}/{{source_dir}}/test_target_full_execution_result.sh",
    ])
    action_pmd_arguments_actual = action_pmd.argv

    action_pmd_inputs_expected = _expand_paths(env.ctx, [
        "{{output_dir}}/{{source_dir}}/srcs_test_target_full.txt",
        "{{source_dir}}/path A.kt",
        "{{source_dir}}/path B.kt",
        "{{source_dir}}/path C.kt",
        "{{output_dir}}/{{source_dir}}/srcs_ignore_test_target_full.txt",
        "{{source_dir}}/path D.kt",
        "{{source_dir}}/path E.kt",
        "{{source_dir}}/rulesets.xml",
        "bazel-out/host/internal/_middlemen/pmd_Swrapper_Sbin-runfiles",
        "bazel-out/host/bin/pmd/wrapper/bin.jar",
        "bazel-out/host/bin/pmd/wrapper/bin",
    ])
    action_pmd_inputs_actual = [file.path for file in action_pmd.inputs.to_list()]

    action_pmd_outputs_expected = _expand_paths(env.ctx, [
        "{{output_dir}}/{{source_dir}}/test_target_full_pmd_report.html",
        "{{output_dir}}/{{source_dir}}/test_target_full_execution_result.sh",
    ])
    action_pmd_outputs_actual = [file.path for file in action_pmd.outputs.to_list()]

    asserts.equals(env, action_pmd_arguments_expected, action_pmd_arguments_actual)
    asserts.equals(env, action_pmd_inputs_expected, action_pmd_inputs_actual)
    asserts.equals(env, action_pmd_outputs_expected, action_pmd_outputs_actual)

    return analysistest.end(env)

action_full_contents_test = analysistest.make(_action_full_contents_test_impl)

def _test_action_full_contents():
    pmd_test(
        name = "test_target_full",
        srcs = ["path A.kt", "path B.kt", "path C.kt"],
        srcs_ignore = ["path D.kt", "path E.kt"],
        srcs_language = "java",
        srcs_language_version = "1.8",
        rulesets = ["rulesets.xml"],
        rules_minimum_priority = 42,
        report_format = "html",
        fail_on_violation = False,
        threads_count = 42,
    )

    action_full_contents_test(
        name = "action_full_contents_test",
        target_under_test = ":test_target_full",
    )

# Action blank contents test

def _action_blank_contents_test_impl(ctx):
    env = analysistest.begin(ctx)

    actions = analysistest.target_actions(env)
    asserts.equals(env, 6, len(actions))

    # Action: writing file "srcs.txt"

    action_write_file_srcs = actions[0]

    action_write_file_srcs_outputs_expected = _expand_paths(env.ctx, [
        "{{output_dir}}/{{source_dir}}/srcs_test_target_blank.txt",
    ])
    action_write_file_srcs_outputs_actual = [file.path for file in action_write_file_srcs.outputs.to_list()]

    asserts.equals(env, action_write_file_srcs_outputs_expected, action_write_file_srcs_outputs_actual)

    # Action: PMD

    action_pmd = actions[1]

    action_pmd_arguments_expected = _expand_paths(env.ctx, [
        "bazel-out/host/bin/pmd/wrapper/bin",
        "--file-list",
        "{{output_dir}}/{{source_dir}}/srcs_test_target_blank.txt",
        "--encoding",
        "UTF-8",
        "-language",
        "java",
        "--rulesets",
        "{{source_dir}}/rulesets.xml",
        "--minimum-priority",
        "5",
        "--format",
        "text",
        "--report-file",
        "{{output_dir}}/{{source_dir}}/test_target_blank_pmd_report.txt",
        "--fail-on-violation",
        "true",
        "--no-cache",
        "--threads",
        "1",
        "--execution-result",
        "{{output_dir}}/{{source_dir}}/test_target_blank_execution_result.sh",
    ])
    action_pmd_arguments_actual = action_pmd.argv

    action_pmd_inputs_expected = _expand_paths(env.ctx, [
        "{{output_dir}}/{{source_dir}}/srcs_test_target_blank.txt",
        "{{source_dir}}/path A.kt",
        "{{source_dir}}/path B.kt",
        "{{source_dir}}/path C.kt",
        "{{source_dir}}/rulesets.xml",
        "bazel-out/host/internal/_middlemen/pmd_Swrapper_Sbin-runfiles",
        "bazel-out/host/bin/pmd/wrapper/bin.jar",
        "bazel-out/host/bin/pmd/wrapper/bin",
    ])
    action_pmd_inputs_actual = [file.path for file in action_pmd.inputs.to_list()]

    action_pmd_outputs_expected = _expand_paths(env.ctx, [
        "{{output_dir}}/{{source_dir}}/test_target_blank_pmd_report.txt",
        "{{output_dir}}/{{source_dir}}/test_target_blank_execution_result.sh",
    ])
    action_pmd_outputs_actual = [file.path for file in action_pmd.outputs.to_list()]

    asserts.equals(env, action_pmd_arguments_expected, action_pmd_arguments_actual)
    asserts.equals(env, action_pmd_inputs_expected, action_pmd_inputs_actual)
    asserts.equals(env, action_pmd_outputs_expected, action_pmd_outputs_actual)

    return analysistest.end(env)

action_blank_contents_test = analysistest.make(_action_blank_contents_test_impl)

def _test_action_blank_contents():
    pmd_test(
        name = "test_target_blank",
        srcs = ["path A.kt", "path B.kt", "path C.kt"],
        rulesets = ["rulesets.xml"],
    )

    action_blank_contents_test(
        name = "action_blank_contents_test",
        target_under_test = ":test_target_blank",
    )

# Suite

def test_suite(name):
    _test_action_full_contents()
    _test_action_blank_contents()

    native.test_suite(
        name = name,
        tests = [
            ":action_full_contents_test",
            ":action_blank_contents_test",
        ],
    )
