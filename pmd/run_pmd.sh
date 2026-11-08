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

# Keep lists, rulesets and outputs connected to the action's execroot.
while [[ $1 != -- ]]; do
    dest="$work/$1"
    if [[ ! -e $dest && ! -L $dest ]]; then
        mkdir -p "$(dirname "$dest")"
        ln -s "$PWD/$1" "$dest"
    fi
    shift
done
shift
(cd "$work" && RULES_PMD_STAGED_SOURCES=1 "$wrapper" "$@")
