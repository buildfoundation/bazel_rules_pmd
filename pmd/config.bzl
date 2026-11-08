"""Reusable PMD analysis policy."""

def _pmd_config_info_init(*, rulesets, rules_minimum_priority, threads_count):
    if type(rulesets) != "list":
        fail("PmdConfigInfo.rulesets must be a list of Files, got {}".format(type(rulesets)))
    for name, value in [("rules_minimum_priority", rules_minimum_priority), ("threads_count", threads_count)]:
        if type(value) != "int":
            fail("PmdConfigInfo.{} must be an int, got {}".format(name, type(value)))
    return {
        "rulesets": rulesets,
        "rules_minimum_priority": rules_minimum_priority,
        "threads_count": threads_count,
    }

PmdConfigInfo, _new_pmd_config_info = provider(
    doc = "Complete PMD analysis policy, selected without per-field inheritance.",
    fields = {
        "rulesets": "Resolved ruleset files (list of File).",
        "rules_minimum_priority": "Minimum rule priority.",
        "threads_count": "Number of analysis threads.",
    },
    init = _pmd_config_info_init,
)

def _impl(ctx):
    return [PmdConfigInfo(
        rulesets = ctx.files.rulesets,
        rules_minimum_priority = ctx.attr.rules_minimum_priority,
        threads_count = ctx.attr.threads_count,
    )]

pmd_config = rule(
    implementation = _impl,
    attrs = {
        "rulesets": attr.label_list(allow_files = True, doc = "PMD ruleset files. Must resolve to at least one file when used by a PMD target."),
        "rules_minimum_priority": attr.int(default = 5, values = [1, 2, 3, 4, 5], doc = "PMD minimum rule priority (1 to 5)."),
        "threads_count": attr.int(default = 1, doc = "Number of PMD analysis threads."),
    },
    provides = [PmdConfigInfo],
)
