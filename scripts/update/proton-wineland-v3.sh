#!/usr/bin/env bash

set -euo pipefail

packages_dir="${1:-}"

if [[ ! -d "${packages_dir}" ]]; then
    echo "Packages directory not found: ${packages_dir}" >&2
    exit 1
fi

package_name="proton-wineland-v3"
updates_api_url="https://api.github.com/repos/nanomatters/proton-cachyos/releases/latest"

cd "${packages_dir}/${package_name}"

auth_header=()
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    auth_header=("-H" "Authorization: Bearer ${GITHUB_TOKEN}")
fi
api_response=$(curl -sL --max-time 10 "${auth_header[@]}" "${updates_api_url}")
if [[ "$(echo "${api_response}" | jq -r '.message // empty')" != "" ]]; then
    echo "GitHub API request failed: $(echo "${api_response}" | jq -r '.message')" >&2
    exit 1
fi
version=$(echo "${api_response}" | jq -r '.tag_name' | sed 's/wineland-//')

if grep -q "_pkgver=${version}" PKGBUILD; then
    echo "PKGBUILD is already up to date with version ${version}."
    exit 0
fi

sha_url=$(echo "${api_response}" | jq -r --arg name "proton-wineland-${version}-x86_64_v3.sha512sum" '.assets[] | select(.name == $name) | .browser_download_url')
sha512hash=$(curl -sL --max-time 10 "${auth_header[@]}" "${sha_url}" | awk '{print $1}')

sed -i "s/_pkgver=.*/_pkgver=${version}/" PKGBUILD
sed -i "s/^sha512sums_x86_64=.*/sha512sums_x86_64=('${sha512hash}')/" PKGBUILD
sed -i "s/pkgrel=.*/pkgrel=1/" PKGBUILD
