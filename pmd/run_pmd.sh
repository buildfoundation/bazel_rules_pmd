#!/usr/bin/env bash
set -euo pipefail

# PMD 7.29 rejects sandbox symlinks. Mirror declared sources as regular files
# under their exec paths so reports and exclusions keep their original names.
wrapper="$PWD/$1"
shift
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
work="$scratch/execroot"
mkdir -p "$work"
while [[ $1 != -- ]]; do
    while IFS= read -r src || [[ -n $src ]]; do
        dest="$work/$src"
        if [[ ! -e $dest ]]; then
            mkdir -p "$(dirname "$dest")"
            cp -RH "./$src" "$dest"
        fi
    done < "$1"
    shift
done
shift

# Copy lists and rulesets in, and outputs back out afterwards. Windows Bash
# cannot symlink to outputs that do not exist yet.
outputs=()
while [[ $1 != -- ]]; do
    dest="$work/$1"
    mkdir -p "$(dirname "$dest")"
    if [[ ! -e $1 ]]; then
        outputs+=("$1")
    elif [[ ! -e $dest ]]; then
        cp -RH "$1" "$dest"
    fi
    shift
done
shift
status=0
(cd "$work" && RULES_PMD_STAGED_SOURCES=1 "$wrapper" "$@") || status=$?
for output in "${outputs[@]}"; do
    if [[ -e $work/$output ]]; then
        cp "$work/$output" "$output"
    fi
done
exit "$status"
