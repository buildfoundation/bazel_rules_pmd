#!/bin/bash

# --- begin runfiles.bash initialization v3 ---
set -uo pipefail; set +e; f=bazel_tools/tools/bash/runfiles/runfiles.bash
# shellcheck disable=SC1090
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v3 ---

runfiles_export_envvars

if ! pmd_result="$(rlocation __PMD_RESULT__)" || [[ -z "${pmd_result}" || ! -f "${pmd_result}" ]]; then
  echo >&2 "ERROR: cannot find PMD execution result"
  exit 1
fi

if [[ -n __PMD_REPORT__ ]]; then
  if ! pmd_report="$(rlocation __PMD_REPORT__)" || [[ -z "${pmd_report}" || ! -f "${pmd_report}" ]]; then
    echo >&2 "ERROR: cannot find PMD report"
    exit 1
  fi
  if [[ -s "${pmd_report}" ]]; then
    cat "${pmd_report}" >&2
  fi
fi

pmd_exit_code="$(<"${pmd_result}")"
exit "${pmd_exit_code}"
