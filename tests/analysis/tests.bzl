"""
The rule analysis tests.
"""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts", "unittest")
load("//pmd:defs.bzl", "pmd_test")
load("//pmd:versions.bzl", "DEFAULT_PMD_RELEASE", "pmd_version")

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

def _expand_paths(ctx, values):
    source_dir = ctx.build_file_path.replace("/BUILD", "")
    output_dir = ctx.bin_dir.path

    return [
        value
            .replace("{{source_dir}}", source_dir)
            .replace("{{output_dir}}", output_dir)
        for value in values
    ]

def _asserted_input_short_paths(action):
    # ponytail: the wrapper runfiles tree is named `_middlemen/…` on Bazel 8 and
    # `…/bin.runfiles` on Bazel 9, so it is skipped instead of asserted.
    return sorted([
        file.short_path
        for file in action.inputs.to_list()
        if not file.short_path.startswith("_middlemen/") and not file.short_path.endswith(".runfiles")
    ])

# Action full contents test

def _action_full_contents_test_impl(ctx):
    env = analysistest.begin(ctx)

    actions = analysistest.target_actions(env)
    asserts.equals(env, 8, len(actions))

    # Action: writing file "srcs.txt"

    action_write_file_srcs = actions[0]

    action_write_file_srcs_outputs_expected = _expand_paths(env.ctx, [
        "{{output_dir}}/{{source_dir}}/srcs_test_target_full.txt",
    ])
    action_write_file_srcs_outputs_actual = [file.path for file in action_write_file_srcs.outputs.to_list()]

    asserts.equals(env, action_write_file_srcs_outputs_expected, action_write_file_srcs_outputs_actual)
    asserts.equals(env, ",".join(_expand_paths(env.ctx, [
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
    asserts.equals(env, ",".join(_expand_paths(env.ctx, [
        "{{source_dir}}/path D.kt",
        "{{source_dir}}/path E.kt",
    ])), action_write_file_srcs_ignore.content)

    # Action: PMD

    action = actions[2]
    assert_argv_contains_prefix_suffix(env, action, "bazel-out/", "/pmd/wrapper/bin")
    assert_argv_contains(env, action, "--file-list")
    assert_argv_contains(env, action, _expand_path(ctx, "{{output_dir}}/{{source_dir}}/srcs_test_target_full.txt"))
    assert_argv_contains(env, action, "--ignore-list")
    assert_argv_contains(env, action, _expand_path(ctx, "{{output_dir}}/{{source_dir}}/srcs_ignore_test_target_full.txt"))
    assert_argv_contains(env, action, "--encoding")
    assert_argv_contains(env, action, "UTF-8")
    assert_argv_contains(env, action, "-language")
    assert_argv_contains(env, action, "java")
    assert_argv_contains(env, action, "-version")
    assert_argv_contains(env, action, "1.8")
    assert_argv_contains(env, action, "--rulesets")
    assert_argv_contains(env, action, _expand_path(ctx, "{{source_dir}}/rulesets.xml"))
    assert_argv_contains(env, action, "--minimum-priority")
    assert_argv_contains(env, action, "42")
    assert_argv_contains(env, action, "--format")
    assert_argv_contains(env, action, "html")
    assert_argv_contains(env, action, "--report-file")
    assert_argv_contains(env, action, _expand_path(ctx, "{{output_dir}}/{{source_dir}}/test_target_full_pmd_report.html"))
    assert_argv_contains(env, action, "--fail-on-violation")
    assert_argv_contains(env, action, "false")
    assert_argv_contains(env, action, "--no-cache")
    assert_argv_contains(env, action, "--threads")
    assert_argv_contains(env, action, "42")
    assert_argv_contains(env, action, "--execution-result")
    assert_argv_contains(env, action, _expand_path(ctx, "{{output_dir}}/{{source_dir}}/test_target_full_execution_result.sh"))

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

    expected_outputs = _expand_paths(env.ctx, [
        "{{source_dir}}/test_target_full_pmd_report.html",
        "{{source_dir}}/test_target_full_execution_result.sh",
    ])

    asserts.equals(env, sorted(expected_inputs), _asserted_input_short_paths(action))
    asserts.equals(env, sorted(expected_outputs), sorted([file.short_path for file in action.outputs.to_list()]))

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
        tags = ["manual"],
    )

    action_full_contents_test(
        name = "action_full_contents_test",
        target_under_test = ":test_target_full",
    )

# Action blank contents test

def _action_blank_contents_test_impl(ctx):
    env = analysistest.begin(ctx)

    actions = analysistest.target_actions(env)
    asserts.equals(env, 7, len(actions))

    # Action: writing file "srcs.txt"

    action_write_file_srcs = actions[0]

    action_write_file_srcs_outputs_expected = _expand_paths(env.ctx, [
        "{{output_dir}}/{{source_dir}}/srcs_test_target_blank.txt",
    ])
    action_write_file_srcs_outputs_actual = [file.path for file in action_write_file_srcs.outputs.to_list()]

    asserts.equals(env, action_write_file_srcs_outputs_expected, action_write_file_srcs_outputs_actual)

    # Action: PMD

    action = actions[1]

    assert_argv_contains_prefix_suffix(env, action, "bazel-out/", "/pmd/wrapper/bin")
    assert_argv_contains(env, action, "--file-list")
    assert_argv_contains(env, action, _expand_path(ctx, "{{output_dir}}/{{source_dir}}/srcs_test_target_blank.txt"))
    assert_argv_contains(env, action, "--encoding")
    assert_argv_contains(env, action, "UTF-8")
    assert_argv_contains(env, action, "-language")
    assert_argv_contains(env, action, "java")
    assert_argv_contains(env, action, "--rulesets")
    assert_argv_contains(env, action, _expand_path(ctx, "{{source_dir}}/rulesets.xml"))
    assert_argv_contains(env, action, "--minimum-priority")
    assert_argv_contains(env, action, "5")
    assert_argv_contains(env, action, "--format")
    assert_argv_contains(env, action, "text")
    assert_argv_contains(env, action, "--report-file")
    assert_argv_contains(env, action, _expand_path(ctx, "{{output_dir}}/{{source_dir}}/test_target_blank_pmd_report.txt"))
    assert_argv_contains(env, action, "--fail-on-violation")
    assert_argv_contains(env, action, "true")
    assert_argv_contains(env, action, "--no-cache")
    assert_argv_contains(env, action, "--threads")
    assert_argv_contains(env, action, "1")
    assert_argv_contains(env, action, "--execution-result")
    assert_argv_contains(env, action, _expand_path(ctx, "{{output_dir}}/{{source_dir}}/test_target_blank_execution_result.sh"))

    expected_inputs = _expand_paths(env.ctx, [
        "{{source_dir}}/srcs_test_target_blank.txt",
        "{{source_dir}}/path A.kt",
        "{{source_dir}}/path B.kt",
        "{{source_dir}}/path C.kt",
        "{{source_dir}}/rulesets.xml",
        "pmd/wrapper/bin",
        "pmd/wrapper/bin.jar",
    ])

    expected_outputs = _expand_paths(env.ctx, [
        "{{source_dir}}/test_target_blank_pmd_report.txt",
        "{{source_dir}}/test_target_blank_execution_result.sh",
    ])

    asserts.equals(env, sorted(expected_inputs), _asserted_input_short_paths(action))
    asserts.equals(env, sorted(expected_outputs), sorted([file.short_path for file in action.outputs.to_list()]))

    return analysistest.end(env)

action_blank_contents_test = analysistest.make(_action_blank_contents_test_impl)

def _test_action_blank_contents():
    pmd_test(
        name = "test_target_blank",
        srcs = ["path A.kt", "path B.kt", "path C.kt"],
        rulesets = ["rulesets.xml"],
        tags = ["manual"],
    )

    action_blank_contents_test(
        name = "action_blank_contents_test",
        target_under_test = ":test_target_blank",
    )

# PMD version URL templates test

def _pmd_version_test_impl(ctx):
    env = unittest.begin(ctx)

    default_urls = [
        "https://github.com/pmd/pmd/releases/download/pmd_releases/{version}/pmd-bin-{version}.zip",
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
    asserts.equals(env, "6.55.0", DEFAULT_PMD_RELEASE.version)
    asserts.equals(env, "21acf96d43cb40d591cacccc1c20a66fc796eaddf69ea61812594447bac7a11d", DEFAULT_PMD_RELEASE.sha256)
    asserts.equals(env, default_urls, DEFAULT_PMD_RELEASE.url_templates)

    return unittest.end(env)

pmd_version_test = unittest.make(_pmd_version_test_impl)

# Suite

def test_suite(name):
    _test_action_full_contents()
    _test_action_blank_contents()
    pmd_version_test(name = "pmd_version_test")

    native.test_suite(
        name = name,
        tests = [
            ":action_full_contents_test",
            ":action_blank_contents_test",
            ":pmd_version_test",
        ],
    )
