#!/usr/bin/env bash

set -euo pipefail

packages_dir="${1:-}"

if [[ ! -d "${packages_dir}" ]]; then
    echo "Packages directory not found: ${packages_dir}" >&2
    exit 1
fi

package_name="morewaita-icon-theme-git"

cd "${packages_dir}/${package_name}"

makepkg -do
git clean -ffd
