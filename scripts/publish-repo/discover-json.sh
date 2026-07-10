#!/usr/bin/env bash

set -euo pipefail

packages_root="${1:-packages}"

if [[ ! -d "${packages_root}" ]]; then
    echo "Packages root not found: ${packages_root}" >&2
    exit 1
fi

mapfile -t pkg_dirs < <(find "${packages_root}" -mindepth 2 -maxdepth 2 -type f -name 'PKGBUILD' -exec dirname {} \; | sort)

if [[ ${#pkg_dirs[@]} -eq 0 ]]; then
    echo "No package directories with PKGBUILD found under ${packages_root}/" >&2
    exit 1
fi

printf '%s\n' "${pkg_dirs[@]}" |
    jq -R '{package_dir: ., artifact_name: (. | gsub("packages/"; ""))}' |
    jq -c -s .
