#!/bin/bash
set -euo pipefail

readonly wrapper="${PWD}/$1"
readonly source="${TEST_SRCDIR}/${TEST_WORKSPACE}/$2"
readonly ruleset="${TEST_SRCDIR}/${TEST_WORKSPACE}/$3"
readonly test_dir="$(mktemp -d "${TEST_TMPDIR}/pmd-wrapper.XXXXXX")"

run_wrapper() {
    local name="$1"
    local expected_status="$2"
    shift 2

    local stdout="${test_dir}/${name}.stdout"
    local stderr="${test_dir}/${name}.stderr"
    set +e
    (cd "${test_dir}" && "${wrapper}" "$@" >"${stdout}" 2>"${stderr}")
    local actual_status=$?
    set -e
    if [[ "${actual_status}" -ne "${expected_status}" ]]; then
        echo "${name}: expected exit ${expected_status}, got ${actual_status}" >&2
        cat "${stdout}" "${stderr}" >&2
        return 1
    fi
}

assert_saved_status() {
    local name="$1"
    local expected_status="$2"
    local output="$3"
    set +e
    bash "${output}"
    local actual_status=$?
    set -e
    if [[ "${actual_status}" -ne "${expected_status}" ]]; then
        echo "${name}: expected saved exit ${expected_status}, got ${actual_status}" >&2
        return 1
    fi
}

run_wrapper missing_help 1 --help
test ! -e "${test_dir}/--help"
run_wrapper missing_args 1
run_wrapper missing_value 1 --execution-result

readonly output_begin="${test_dir}/begin.sh"
readonly output_end="${test_dir}/result with spaces.sh"
readonly output_usage="${test_dir}/usage.sh"
readonly output_version="${test_dir}/version.sh"
readonly output_violation="${test_dir}/violation.sh"
readonly spaced_source_dir="${test_dir}/source dir"
readonly source_list="${test_dir}/source list.txt"
mkdir -p "${spaced_source_dir}"
cp "${source}" "${spaced_source_dir}/A.java"
printf '%s\n' "${spaced_source_dir}/A.java" >"${source_list}"
run_wrapper valid_begin 0 --execution-result "${output_begin}" --help
run_wrapper valid_end 0 --help --execution-result "${output_end}"
run_wrapper usage_error 0 --execution-result "${output_usage}"
run_wrapper version 0 --execution-result "${output_version}" --version
run_wrapper violation 0 --execution-result "${output_violation}" check \
    --file-list "${source_list}" \
    --rulesets "${ruleset}" \
    --format text \
    --report-file "${test_dir}/violation.txt" \
    --no-progress

test -f "${output_begin}"
test -f "${output_end}"
assert_saved_status valid_begin 0 "${output_begin}"
assert_saved_status valid_end 0 "${output_end}"
assert_saved_status usage_error 2 "${output_usage}"
assert_saved_status version 0 "${output_version}"
assert_saved_status violation 4 "${output_violation}"
grep -Fq "7.26.0" "${test_dir}/version.stdout"
test -s "${test_dir}/violation.txt"
