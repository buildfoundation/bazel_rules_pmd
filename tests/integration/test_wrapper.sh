#!/bin/bash
set -euo pipefail

readonly wrapper="${PWD}/$1"
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

run_wrapper missing_help 1 --help
test ! -e "${test_dir}/--help"
run_wrapper missing_args 1
run_wrapper missing_value 1 --execution-result

readonly output_begin="${test_dir}/begin.sh"
readonly output_end="${test_dir}/result with spaces.sh"
run_wrapper valid_begin 0 --execution-result "${output_begin}" --help
run_wrapper valid_end 0 --help --execution-result "${output_end}"

test -f "${output_begin}"
test -f "${output_end}"
bash "${output_begin}"
bash "${output_end}"
