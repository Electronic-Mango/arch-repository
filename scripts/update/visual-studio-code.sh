#!/usr/bin/env bash

set -euo pipefail

packages_dir="${1:-}"

if [[ ! -d "${packages_dir}" ]]; then
    echo "Packages directory not found: ${packages_dir}" >&2
    exit 1
fi

package_name="visual-studio-code"
updates_api_url="https://update.code.visualstudio.com/api/update/linux-x64/stable/latest"

api_response=$(curl -sL "${updates_api_url}")
version=$(echo "${api_response}" | jq -r '.name')
sha256hash=$(echo "${api_response}" | jq -r '.sha256hash')

pkgbuild_file=$(find "${packages_dir}" -type f -path "*/${package_name}/PKGBUILD" -print -quit)

if [[ -z "${pkgbuild_file}" ]]; then
    echo "PKGBUILD file not found for ${package_name} in ${packages_dir}" >&2
    exit 1
fi

if grep -q "pkgver=${version}" "${pkgbuild_file}"; then
    echo "PKGBUILD is already up to date with version ${version}."
    exit 0
fi

sed -i "s/^pkgver=.*/pkgver=${version}/" "${pkgbuild_file}"
sed -i "s/^sha256sums_x86_64=.*/sha256sums_x86_64=('${sha256hash}')/" "${pkgbuild_file}"
