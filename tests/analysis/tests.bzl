"""
The rule analysis tests.
"""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts", "unittest")
load("//pmd:config.bzl", "pmd_config")
load("//pmd:defs.bzl", "pmd", "pmd_test")
load("//pmd:versions.bzl", "DEFAULT_PMD_RELEASE", "pmd_version")

def _assert_rule_kind(name, expected):
    rule = native.existing_rule(name)
    if rule == None or rule["kind"] != expected:
        fail("Expected {} to have kind {}, got {}".format(name, expected, rule))
    for option in [
        "fail_on_violation",
        "rules_minimum_priority",
        "rulesets",
        "threads_count",
        "_executable",
        "pmd_toolchain",
    ]:
        if option in rule:
            fail("{} must be configured on pmd_config, not {}".format(option, expected))

def _expand_path(ctx, value):
    source_dir = ctx.build_file_path.replace("/BUILD", "")
    output_dir = ctx.bin_dir.path
    return value.replace("{{source_dir}}", source_dir).replace("{{output_dir}}", output_dir)

def assert_argv_contains_prefix_suffix(env, action, prefix, suffix):
    for arg in action.argv:
        if arg.startswith(prefix) and arg.endswith(suffix):
            return
    unittest.fail(
        env,
        "Expected an arg with prefix '{prefix}' and suffix '{suffix}' in {args}".format(
            prefix = prefix,
            suffix = suffix,
            args = action.argv,
        ),
    )

def assert_argv_contains(env, action, flag):
    asserts.true(
        env,
        flag in action.argv,
        "Expected {args} to contain {flag}".format(args = action.argv, flag = flag),
    )

def assert_argv_lacks(env, action, flag):
    asserts.false(
        env,
        flag in action.argv,
        "Expected {args} to not contain {flag}".format(args = action.argv, flag = flag),
    )

def _expand_paths(ctx, values):
    source_dir = ctx.build_file_path.replace("/BUILD", "")
    output_dir = ctx.bin_dir.path

    return [
        value
            .replace("{{source_dir}}", source_dir)
            .replace("{{output_dir}}", output_dir)
        for value in values
    ]

def _input_short_path(file):
    path = file.short_path
    prefix = "_middlemen/"
    suffix = "-runfiles"
    if path.startswith(prefix) and path.endswith(suffix):
        return path[len(prefix):len(path) - len(suffix)].replace("_S", "/") + ".runfiles"
    return path

def _input_short_paths(files):
    return [_input_short_path(file) for file in files.to_list()]

def _asserted_input_short_paths(action):
    return sorted([
        path
        for path in _input_short_paths(action.inputs)
        if not path.endswith(".runfiles")
    ])

def assert_input_contains(env, action, path):
    asserts.true(
        env,
        path in _input_short_paths(action.inputs),
        "Expected action inputs to contain {path}: {inputs}".format(
            path = path,
            inputs = _input_short_paths(action.inputs),
        ),
    )

def assert_input_contains_suffix(env, action, suffix):
    for path in _input_short_paths(action.inputs):
        if path.endswith(suffix):
            return
    unittest.fail(
        env,
        "Expected action inputs to contain a path ending with '{suffix}': {inputs}".format(
            suffix = suffix,
            inputs = _input_short_paths(action.inputs),
        ),
    )

def _assert_public_files_and_runfiles(env, report, execution_result, pmd_result):
    target = analysistest.target_under_test(env)
    default_info = target[DefaultInfo]

    asserts.equals(env, sorted([report, execution_result]), sorted([
        file.short_path
        for file in default_info.files.to_list()
    ]))

    runfile_paths = [
        file.short_path
        for file in default_info.default_runfiles.files.to_list()
    ]
    asserts.true(env, report in runfile_paths)
    asserts.true(env, execution_result in runfile_paths)
    asserts.true(env, pmd_result in runfile_paths)

# Action full contents test

def _action_full_contents_test_impl(ctx):
    env = analysistest.begin(ctx)

    actions = analysistest.target_actions(env)
    asserts.equals(env, 9, len(actions))

    # Action: writing file "srcs.txt"

    action_write_file_srcs = actions[0]

    action_write_file_srcs_outputs_expected = _expand_paths(env.ctx, [
        "{{output_dir}}/{{source_dir}}/srcs_test_target_full.txt",
    ])
    action_write_file_srcs_outputs_actual = [file.path for file in action_write_file_srcs.outputs.to_list()]

    asserts.equals(env, action_write_file_srcs_outputs_expected, action_write_file_srcs_outputs_actual)
    asserts.equals(env, "\n".join(_expand_paths(env.ctx, [
        "{{source_dir}}/path A.kt",
        "{{source_dir}}/path B.kt",
        "{{source_dir}}/path C.kt",
    ])), action_write_file_srcs.content)

    # Action: writing file "srcs_ignore.txt"

    action_write_file_srcs_ignore = actions[1]

    action_write_file_srcs_ignore_ouptuts_expected = _expand_paths(env.ctx, [
        "{{output_dir}}/{{source_dir}}/srcs_ignore_test_target_full.txt",
    ])
    action_write_file_srcs_ignore_ouptuts_actual = [file.path for file in action_write_file_srcs_ignore.outputs.to_list()]

    asserts.equals(env, action_write_file_srcs_ignore_ouptuts_expected, action_write_file_srcs_ignore_ouptuts_actual)
    asserts.equals(env, "\n".join(_expand_paths(env.ctx, [
        "{{source_dir}}/path D.kt",
        "{{source_dir}}/path E.kt",
    ])), action_write_file_srcs_ignore.content)

    # Action: PMD

    action = actions[2]
    assert_argv_contains_prefix_suffix(env, action, "bazel-out/", "/pmd/wrapper/bin")
    assert_argv_contains(env, action, "--file-list")
    assert_argv_contains(env, action, _expand_path(ctx, "{{output_dir}}/{{source_dir}}/srcs_test_target_full.txt"))
    assert_argv_contains(env, action, "--exclude-file-list")
    assert_argv_contains(env, action, _expand_path(ctx, "{{output_dir}}/{{source_dir}}/srcs_ignore_test_target_full.txt"))
    assert_argv_contains(env, action, "--encoding")
    assert_argv_contains(env, action, "UTF-8")
    assert_argv_contains(env, action, "--force-language")
    assert_argv_contains(env, action, "java")
    assert_argv_contains(env, action, "--use-version")
    assert_argv_contains(env, action, "java-1.8")
    assert_argv_contains(env, action, "--rulesets")
    assert_argv_contains(env, action, _expand_path(ctx, "{{source_dir}}/rulesets.xml"))
    assert_argv_contains(env, action, "--minimum-priority")
    assert_argv_contains(env, action, "3")
    assert_argv_contains(env, action, "--format")
    assert_argv_contains(env, action, "html")
    assert_argv_contains(env, action, "--report-file")
    assert_argv_contains(env, action, _expand_path(ctx, "{{output_dir}}/{{source_dir}}/test_target_full_pmd_report.html"))
    assert_argv_contains(env, action, "--no-fail-on-violation")
    assert_argv_contains(env, action, "--no-cache")
    assert_argv_contains(env, action, "--no-progress")
    assert_argv_contains(env, action, "--threads")
    assert_argv_contains(env, action, "42")
    assert_argv_contains(env, action, "--execution-result")
    assert_argv_contains(env, action, _expand_path(ctx, "{{output_dir}}/{{source_dir}}/test_target_full_pmd_result.txt"))

    expected_inputs = _expand_paths(env.ctx, [
        "{{source_dir}}/srcs_test_target_full.txt",
        "{{source_dir}}/path A.kt",
        "{{source_dir}}/path B.kt",
        "{{source_dir}}/path C.kt",
        "{{source_dir}}/srcs_ignore_test_target_full.txt",
        "{{source_dir}}/path D.kt",
        "{{source_dir}}/path E.kt",
        "{{source_dir}}/rulesets.xml",
        "pmd/wrapper/bin",
        "pmd/wrapper/bin.jar",
    ])

    assert_input_contains(env, action, "pmd/wrapper/bin.runfiles")

    expected_outputs = _expand_paths(env.ctx, [
        "{{source_dir}}/test_target_full_pmd_report.html",
        "{{source_dir}}/test_target_full_pmd_result.txt",
    ])

    asserts.equals(env, sorted(expected_inputs), _asserted_input_short_paths(action))
    asserts.equals(env, sorted(expected_outputs), sorted([file.short_path for file in action.outputs.to_list()]))

    # Action: public execution result launcher

    action_launcher = actions[3]
    asserts.equals(env, "TemplateExpand", action_launcher.mnemonic)
    asserts.equals(env, [
        "tests/analysis/test_target_full_execution_result.sh",
    ], [file.short_path for file in action_launcher.outputs.to_list()])
    asserts.equals(env, ["pmd/execution_result.sh.tpl"], _asserted_input_short_paths(action_launcher))
    _assert_public_files_and_runfiles(
        env,
        "tests/analysis/test_target_full_pmd_report.html",
        "tests/analysis/test_target_full_execution_result.sh",
        "tests/analysis/test_target_full_pmd_result.txt",
    )

    return analysistest.end(env)

action_full_contents_test = analysistest.make(_action_full_contents_test_impl)

def _test_action_full_contents():
    pmd_config(
        name = "full_config",
        fail_on_violation = False,
        rules_minimum_priority = 3,
        rulesets = ["rulesets.xml"],
        threads_count = 42,
    )
    pmd_test(
        name = "test_target_full",
        srcs = ["path A.kt", "path B.kt", "path C.kt"],
        srcs_ignore = ["path D.kt", "path E.kt"],
        srcs_language = "java",
        srcs_language_version = "1.8",
        config = ":full_config",
        report_format = "html",
        tags = ["manual"],
    )
    _assert_rule_kind("test_target_full", "pmd_test")

    action_full_contents_test(
        name = "action_full_contents_test",
        target_under_test = ":test_target_full",
    )

# Action blank contents test

def _action_blank_contents_test_impl(ctx):
    env = analysistest.begin(ctx)

    actions = analysistest.target_actions(env)
    asserts.equals(env, 8, len(actions))

    # Action: writing file "srcs.txt"

    action_write_file_srcs = actions[0]

    action_write_file_srcs_outputs_expected = _expand_paths(env.ctx, [
        "{{output_dir}}/{{source_dir}}/srcs_test_target_blank.txt",
    ])
    action_write_file_srcs_outputs_actual = [file.path for file in action_write_file_srcs.outputs.to_list()]

    asserts.equals(env, action_write_file_srcs_outputs_expected, action_write_file_srcs_outputs_actual)

    # Action: PMD

    action = actions[1]

    asserts.equals(env, [], [arg for arg in action.argv if arg.startswith("--jvm_flag")])
    assert_argv_contains_prefix_suffix(env, action, "bazel-out/", "/pmd/wrapper/bin")
    assert_argv_contains(env, action, "--file-list")
    assert_argv_contains(env, action, _expand_path(ctx, "{{output_dir}}/{{source_dir}}/srcs_test_target_blank.txt"))
    assert_argv_contains(env, action, "--encoding")
    assert_argv_contains(env, action, "UTF-8")
    assert_argv_contains(env, action, "--force-language")
    assert_argv_contains(env, action, "java")
    assert_argv_contains(env, action, "--rulesets")
    assert_argv_contains(env, action, _expand_path(ctx, "{{source_dir}}/rulesets.xml"))
    assert_argv_contains(env, action, "--minimum-priority")
    assert_argv_contains(env, action, "5")
    assert_argv_contains(env, action, "--format")
    assert_argv_contains(env, action, "text")
    assert_argv_contains(env, action, "--report-file")
    assert_argv_contains(env, action, _expand_path(ctx, "{{output_dir}}/{{source_dir}}/test_target_blank_pmd_report.txt"))
    assert_argv_lacks(env, action, "--no-fail-on-violation")
    assert_argv_contains(env, action, "--no-cache")
    assert_argv_contains(env, action, "--no-progress")
    assert_argv_contains(env, action, "--threads")
    assert_argv_contains(env, action, "1")
    assert_argv_contains(env, action, "--execution-result")
    assert_argv_contains(env, action, _expand_path(ctx, "{{output_dir}}/{{source_dir}}/test_target_blank_pmd_result.txt"))

    expected_inputs = _expand_paths(env.ctx, [
        "{{source_dir}}/srcs_test_target_blank.txt",
        "{{source_dir}}/path A.kt",
        "{{source_dir}}/path B.kt",
        "{{source_dir}}/path C.kt",
        "{{source_dir}}/rulesets.xml",
        "pmd/wrapper/bin",
        "pmd/wrapper/bin.jar",
    ])

    assert_input_contains(env, action, "pmd/wrapper/bin.runfiles")

    expected_outputs = _expand_paths(env.ctx, [
        "{{source_dir}}/test_target_blank_pmd_report.txt",
        "{{source_dir}}/test_target_blank_pmd_result.txt",
    ])

    asserts.equals(env, sorted(expected_inputs), _asserted_input_short_paths(action))
    asserts.equals(env, sorted(expected_outputs), sorted([file.short_path for file in action.outputs.to_list()]))

    # Action: public execution result launcher

    action_launcher = actions[2]
    asserts.equals(env, "TemplateExpand", action_launcher.mnemonic)
    asserts.equals(env, [
        "tests/analysis/test_target_blank_execution_result.sh",
    ], [file.short_path for file in action_launcher.outputs.to_list()])
    asserts.equals(env, ["pmd/execution_result.sh.tpl"], _asserted_input_short_paths(action_launcher))
    _assert_public_files_and_runfiles(
        env,
        "tests/analysis/test_target_blank_pmd_report.txt",
        "tests/analysis/test_target_blank_execution_result.sh",
        "tests/analysis/test_target_blank_pmd_result.txt",
    )

    return analysistest.end(env)

action_blank_contents_test = analysistest.make(_action_blank_contents_test_impl)

def _test_action_blank_contents():
    pmd_config(
        name = "blank_config",
        rulesets = ["rulesets.xml"],
    )
    pmd_test(
        name = "test_target_blank",
        srcs = ["path A.kt", "path B.kt", "path C.kt"],
        config = ":blank_config",
        tags = ["manual"],
    )

    action_blank_contents_test(
        name = "action_blank_contents_test",
        target_under_test = ":test_target_blank",
    )

# Build rule contents test

def _action_build_contents_test_impl(ctx):
    env = analysistest.begin(ctx)

    actions = analysistest.target_actions(env)
    pmd_actions = [action for action in actions if action.mnemonic == "PMD"]
    asserts.equals(env, 1, len(pmd_actions))

    action = pmd_actions[0]
    assert_argv_contains(env, action, "check")
    assert_argv_contains(env, action, "--report-file")
    assert_argv_contains(env, action, _expand_path(ctx, "{{output_dir}}/{{source_dir}}/pmd_target_build_pmd_report.txt"))
    assert_argv_lacks(env, action, "--no-fail-on-violation")
    asserts.equals(env, [], [arg for arg in action.argv if arg == "--execution-result"])
    asserts.equals(env, 0, len([action for action in actions if action.mnemonic == "TemplateExpand"]))

    expected_inputs = _expand_paths(env.ctx, [
        "{{source_dir}}/srcs_pmd_target_build.txt",
        "{{source_dir}}/path A.kt",
        "{{source_dir}}/rulesets.xml",
        "pmd/wrapper/bin",
        "pmd/wrapper/bin.jar",
    ])
    expected_outputs = _expand_paths(env.ctx, [
        "{{source_dir}}/pmd_target_build_pmd_report.txt",
    ])

    asserts.equals(env, sorted(expected_inputs), _asserted_input_short_paths(action))
    asserts.equals(env, sorted(expected_outputs), sorted([file.short_path for file in action.outputs.to_list()]))

    default_info = analysistest.target_under_test(env)[DefaultInfo]
    asserts.equals(env, sorted(expected_outputs), sorted([file.short_path for file in default_info.files.to_list()]))
    asserts.equals(env, None, default_info.files_to_run.executable)
    asserts.equals(env, [], [file.short_path for file in default_info.default_runfiles.files.to_list()])

    return analysistest.end(env)

action_build_contents_test = analysistest.make(_action_build_contents_test_impl)

def _test_action_build_contents():
    pmd(
        name = "pmd_target_build",
        config = ":blank_config",
        srcs = ["path A.kt"],
        tags = ["manual"],
    )

    action_build_contents_test(
        name = "action_build_contents_test",
        target_under_test = ":pmd_target_build",
    )

# Build rule failure policy test

def _action_build_no_fail_policy_test_impl(ctx):
    env = analysistest.begin(ctx)

    pmd_actions = [action for action in analysistest.target_actions(env) if action.mnemonic == "PMD"]
    asserts.equals(env, 1, len(pmd_actions))

    action = pmd_actions[0]
    assert_argv_contains(env, action, "--no-fail-on-violation")
    assert_argv_lacks(env, action, "--execution-result")

    return analysistest.end(env)

action_build_no_fail_policy_test = analysistest.make(_action_build_no_fail_policy_test_impl)

def _test_action_build_no_fail_policy():
    pmd_config(
        name = "build_no_fail_config",
        fail_on_violation = False,
        rulesets = ["rulesets.xml"],
    )
    pmd(
        name = "pmd_target_build_no_fail",
        config = ":build_no_fail_config",
        srcs = ["path A.kt"],
        tags = ["manual"],
    )

    action_build_no_fail_policy_test(
        name = "action_build_no_fail_policy_test",
        target_under_test = ":pmd_target_build_no_fail",
    )

# Registered toolchains apply when a rule does not select an explicit profile.

def _test_registered_toolchain_target():
    pmd_test(
        name = "test_target_registered",
        srcs = ["path A.kt", "path B.kt", "path C.kt"],
        tags = ["manual"],
    )
    _assert_rule_kind("test_target_registered", "pmd_test")

# Registered profile selection test

def _action_registered_profile_test_impl(ctx):
    env = analysistest.begin(ctx)

    actions = analysistest.target_actions(env)
    pmd_actions = [action for action in actions if action.mnemonic == "PMD"]
    asserts.equals(env, 1, len(pmd_actions))

    action = pmd_actions[0]
    asserts.equals(env, [], [arg for arg in action.argv if arg.startswith("--jvm_flag")])
    asserts.equals(env, "check", action.argv[1])
    asserts.equals(env, "--file-list", action.argv[2])
    assert_argv_contains(env, action, "--rulesets")
    assert_argv_contains(env, action, _expand_path(ctx, "{{source_dir}}/registered_rulesets.xml"))
    assert_argv_contains(env, action, "--minimum-priority")
    assert_argv_contains(env, action, "4")
    assert_argv_contains(env, action, "--no-fail-on-violation")
    assert_argv_contains(env, action, "--threads")
    assert_argv_contains(env, action, "17")
    assert_input_contains(env, action, _expand_path(ctx, "{{source_dir}}/registered_rulesets.xml"))

    return analysistest.end(env)

action_registered_profile_test = analysistest.make(
    _action_registered_profile_test_impl,
    config_settings = {
        "//command_line_option:extra_toolchains": ["//tests/analysis:custom_toolchain"],
    },
)

# Explicit profiles select all shared settings without inheriting the registered profile.

def _action_config_a_test_impl(ctx):
    env = analysistest.begin(ctx)

    actions = [action for action in analysistest.target_actions(env) if action.mnemonic == "PMD"]
    asserts.equals(env, 1, len(actions))

    action = actions[0]
    assert_argv_contains_prefix_suffix(env, action, "bazel-out/", "/tests/analysis/custom_pmd_wrapper")
    assert_argv_contains(env, action, "--rulesets")
    assert_argv_contains(env, action, _expand_path(ctx, "{{source_dir}}/rulesets_a.xml"))
    assert_argv_contains(env, action, "--minimum-priority")
    assert_argv_contains(env, action, "1")
    assert_argv_lacks(env, action, "--no-fail-on-violation")
    assert_argv_contains(env, action, "--threads")
    assert_argv_contains(env, action, "3")
    asserts.equals(env, [], [arg for arg in action.argv if arg.startswith("--jvm_flag")])
    assert_input_contains(env, action, _expand_path(ctx, "{{source_dir}}/rulesets_a.xml"))
    assert_input_contains_suffix(env, action, "/custom_pmd_wrapper")
    asserts.false(
        env,
        _expand_path(ctx, "{{source_dir}}/registered_rulesets.xml") in _input_short_paths(action.inputs),
        "Explicit profile must not inherit registered rulesets",
    )

    return analysistest.end(env)

action_config_a_test = analysistest.make(
    _action_config_a_test_impl,
    config_settings = {
        "//command_line_option:extra_toolchains": ["//tests/analysis:custom_toolchain"],
    },
)

def _test_action_config_a():
    pmd(
        name = "test_target_config_a",
        config = ":config_a",
        srcs = ["path A.kt"],
        tags = ["manual"],
    )
    _assert_rule_kind("test_target_config_a", "pmd")
    action_config_a_test(
        name = "action_config_a_test",
        target_under_test = ":test_target_config_a",
    )

def _action_config_b_test_impl(ctx):
    env = analysistest.begin(ctx)

    actions = [action for action in analysistest.target_actions(env) if action.mnemonic == "PMD"]
    asserts.equals(env, 1, len(actions))

    action = actions[0]
    assert_argv_contains_prefix_suffix(env, action, "bazel-out/", "/pmd/wrapper/bin")
    assert_argv_contains(env, action, "--rulesets")
    assert_argv_contains_prefix_suffix(env, action, "bazel-out/", "/tests/analysis/generated_ruleset.xml")
    assert_argv_contains(env, action, "--minimum-priority")
    assert_argv_contains(env, action, "2")
    assert_argv_contains(env, action, "--no-fail-on-violation")
    assert_argv_contains(env, action, "--threads")
    assert_argv_contains(env, action, "7")
    assert_input_contains(env, action, _expand_path(ctx, "{{source_dir}}/generated_ruleset.xml"))
    assert_input_contains(env, action, "pmd/wrapper/bin.runfiles")
    asserts.false(
        env,
        _expand_path(ctx, "{{source_dir}}/rulesets_a.xml") in _input_short_paths(action.inputs),
        "Independent profiles must not inherit another profile's rulesets",
    )

    return analysistest.end(env)

action_config_b_test = analysistest.make(_action_config_b_test_impl)

def _test_action_config_b():
    pmd_test(
        name = "test_target_config_b",
        config = ":config_b",
        srcs = ["path A.kt"],
        tags = ["manual"],
    )
    action_config_b_test(
        name = "action_config_b_test",
        target_under_test = ":test_target_config_b",
    )

# select() chooses a complete profile; its settings do not merge with the other branch.

def _action_select_test_impl(ctx):
    env = analysistest.begin(ctx)

    actions = [action for action in analysistest.target_actions(env) if action.mnemonic == "PMD"]
    asserts.equals(env, 1, len(actions))

    action = actions[0]
    assert_argv_contains_prefix_suffix(env, action, "bazel-out/", "/tests/analysis/generated_ruleset.xml")
    assert_argv_contains(env, action, "--minimum-priority")
    assert_argv_contains(env, action, "2")
    assert_argv_contains(env, action, "--no-fail-on-violation")
    assert_argv_contains(env, action, "--threads")
    assert_argv_contains(env, action, "7")

    return analysistest.end(env)

action_select_test = analysistest.make(
    _action_select_test_impl,
    config_settings = {
        "//command_line_option:compilation_mode": "opt",
    },
)

def _test_action_select():
    pmd(
        name = "test_target_select",
        config = select({
            ":select_config_b": ":config_b",
            "//conditions:default": ":config_a",
        }),
        srcs = ["path A.kt"],
        tags = ["manual"],
    )
    action_select_test(
        name = "action_select_test",
        target_under_test = ":test_target_select",
    )

# Empty filegroups must fail during analysis with an actionable profile error.

def _action_missing_rulesets_test_impl(ctx):
    env = analysistest.begin(ctx)
    asserts.expect_failure(env, "no ruleset files")
    return analysistest.end(env)

action_missing_rulesets_test = analysistest.make(
    _action_missing_rulesets_test_impl,
    expect_failure = True,
)

def _test_action_missing_rulesets():
    pmd(
        name = "test_target_missing_rulesets",
        config = ":empty_config",
        srcs = ["path A.kt"],
        tags = ["manual"],
    )
    action_missing_rulesets_test(
        name = "action_missing_rulesets_test",
        target_under_test = ":test_target_missing_rulesets",
    )
    pmd(
        name = "test_target_missing_default_rulesets",
        srcs = ["path A.kt"],
        tags = ["manual"],
    )
    action_missing_rulesets_test(
        name = "action_missing_default_rulesets_test",
        target_under_test = ":test_target_missing_default_rulesets",
    )

# PMD 6 language aliases retained by the public rule API

def _action_language_alias_test_impl(ctx):
    env = analysistest.begin(ctx)

    actions = analysistest.target_actions(env)
    pmd_actions = [action for action in actions if action.mnemonic == "PMD"]
    asserts.equals(env, 1, len(pmd_actions))

    action = pmd_actions[0]
    assert_argv_contains(env, action, "check")
    assert_argv_contains(env, action, "--force-language")
    assert_argv_contains(env, action, ctx.attr.expected_language)
    assert_argv_contains(env, action, "--use-version")
    assert_argv_contains(env, action, "{}-1.8".format(ctx.attr.expected_language))

    return analysistest.end(env)

action_language_alias_test = analysistest.make(
    _action_language_alias_test_impl,
    attrs = {
        "expected_language": attr.string(mandatory = True),
    },
)

def _test_action_language_alias(language, expected_language):
    target_name = "test_target_language_alias_{}".format(language)
    test_name = "action_language_alias_{}_test".format(language)

    pmd_test(
        name = target_name,
        srcs = ["path A.kt"],
        config = ":blank_config",
        srcs_language = language,
        srcs_language_version = "1.8",
        tags = ["manual"],
    )

    action_language_alias_test(
        name = test_name,
        expected_language = expected_language,
        target_under_test = ":{}".format(target_name),
    )

# PMD version URL templates test

def _pmd_version_test_impl(ctx):
    env = unittest.begin(ctx)

    default_urls = [
        "https://github.com/pmd/pmd/releases/download/pmd_releases/{version}/pmd-dist-{version}-bin.zip",
    ]
    original = pmd_version("1.2.3", "original-sha")
    explicit_none = pmd_version("1.2.3", "original-sha", None)
    custom_urls = [
        "https://mirror.example.com/pmd/{version}.zip",
        "https://backup.example.com/pmd/pmd-{version}.zip",
    ]
    custom = pmd_version("7.0.0", "custom-sha", custom_urls)

    asserts.equals(env, default_urls, original.url_templates)
    asserts.equals(env, default_urls, explicit_none.url_templates)
    asserts.equals(env, "7.0.0", custom.version)
    asserts.equals(env, "custom-sha", custom.sha256)
    asserts.equals(env, custom_urls, custom.url_templates)
    asserts.equals(env, "7.26.0", DEFAULT_PMD_RELEASE.version)
    asserts.equals(env, "9f55cb7ff0e9f9a66dd2f005eaa370e84c8a4cd971b134aa14a930c4a283ebc9", DEFAULT_PMD_RELEASE.sha256)
    asserts.equals(env, default_urls, DEFAULT_PMD_RELEASE.url_templates)

    return unittest.end(env)

pmd_version_test = unittest.make(_pmd_version_test_impl)

# Suite

def test_suite(name):
    """Create PMD rule analysis and version tests.

    Args:
      name: Name of the test suite.
    """
    _test_action_full_contents()
    _test_action_blank_contents()
    _test_action_build_contents()
    _test_action_build_no_fail_policy()
    _test_registered_toolchain_target()
    _test_action_config_a()
    _test_action_config_b()
    _test_action_select()
    _test_action_missing_rulesets()
    _test_action_language_alias("vf", "visualforce")
    _test_action_language_alias("vm", "velocity")
    action_registered_profile_test(
        name = "action_registered_profile_test",
        target_under_test = ":test_target_registered",
    )
    pmd_version_test(name = "pmd_version_test")

    native.test_suite(
        name = name,
        tests = [
            ":action_full_contents_test",
            ":action_blank_contents_test",
            ":action_build_contents_test",
            ":action_build_no_fail_policy_test",
            ":action_config_a_test",
            ":action_config_b_test",
            ":action_select_test",
            ":action_missing_rulesets_test",
            ":action_missing_default_rulesets_test",
            ":action_language_alias_vf_test",
            ":action_language_alias_vm_test",
            ":action_registered_profile_test",
            ":pmd_version_test",
        ],
    )
