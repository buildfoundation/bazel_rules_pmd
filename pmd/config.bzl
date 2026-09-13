"""Reusable PMD analysis policy."""

PmdConfigInfo = provider(
    doc = "Complete PMD analysis policy, selected without per-field inheritance.",
    fields = {
        "rulesets": "Resolved ruleset files.",
        "rules_minimum_priority": "Minimum rule priority.",
        "fail_on_violation": "Whether violations fail the action or test.",
        "threads_count": "Number of analysis threads.",
    },
)

def _impl(ctx):
    return [PmdConfigInfo(
        rulesets = ctx.files.rulesets,
        rules_minimum_priority = ctx.attr.rules_minimum_priority,
        fail_on_violation = ctx.attr.fail_on_violation,
        threads_count = ctx.attr.threads_count,
    )]

pmd_config = rule(
    implementation = _impl,
    attrs = {
        "rulesets": attr.label_list(allow_files = True, doc = "PMD ruleset files. Must resolve to at least one file when used by a PMD target."),
        "rules_minimum_priority": attr.int(default = 5, doc = "PMD minimum rule priority."),
        "fail_on_violation": attr.bool(default = True, doc = "Fail when PMD reports violations."),
        "threads_count": attr.int(default = 1, doc = "Number of PMD analysis threads."),
    },
    provides = [PmdConfigInfo],
)
