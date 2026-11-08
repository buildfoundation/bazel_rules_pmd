#!/usr/bin/env bash
set -euo pipefail

# Usage: run_pmd.sh <wrapper> <files to link>... -- <PMD arguments>...
#
# PMD 7.29 rejects sandbox symlinks. Mirror the sources named by --file-list and
# --exclude-file-list as regular files under their exec paths so reports and
# exclusions keep their original names, and link the remaining files (rulesets,
# outputs, the file lists themselves) back to the action's execroot.
wrapper="$PWD/$1"
shift
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
work="$scratch/execroot"
mkdir -p "$work"

links=()
while [[ $1 != -- ]]; do
    links+=("$1")
    shift
done
shift

for arg in "$@"; do
    case $arg in
    --file-list=* | --exclude-file-list=*)
        list=${arg#*=}
        links+=("$list")
        while IFS= read -r src || [[ -n $src ]]; do
            dest="$work/$src"
            if [[ ! -e $dest ]]; then
                mkdir -p "$(dirname "$dest")"
                cp -RH "./$src" "$dest"
            fi
        done <"$list"
        ;;
    esac
done

for file in "${links[@]}"; do
    dest="$work/$file"
    if [[ ! -e $dest && ! -L $dest ]]; then
        mkdir -p "$(dirname "$dest")"
        ln -s "$PWD/$file" "$dest"
    fi
done

(cd "$work" && RULES_PMD_STAGED_SOURCES=1 "$wrapper" "$@")
