#!/usr/bin/env bash

set -euo pipefail

packages_dir="${1:-}"

if [[ ! -d "${packages_dir}" ]]; then
    echo "Packages directory not found: ${packages_dir}" >&2
    exit 1
fi

package_name="proton-ge-custom"
updates_api_url="https://api.github.com/repos/GloriousEggroll/${package_name}/releases/latest"

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
version=$(echo "${api_response}" | jq -r '.tag_name')
sha_url=$(echo "${api_response}" | jq -r --arg name "${version}-x86_64.sha512sum" '.assets[] | select(.name == $name) | .browser_download_url')
sha512hash=$(curl -sL --max-time 10 "${auth_header[@]}" "${sha_url}" | awk '{print $1}')

old_pkgver=$(grep -Po "_pkgver=\K.+" PKGBUILD)
old_pkgrel=$(grep -Po "pkgrel=\K.+" PKGBUILD)

sed -i "s/_pkgver=.*/_pkgver=${version}/" PKGBUILD
sed -i "s/^sha512sums_x86_64=.*/sha512sums_x86_64=('${sha512hash}')/" PKGBUILD

if git diff --quiet PKGBUILD; then
    echo "No changes detected, skipping."
    exit 0
fi

if [[ "${old_pkgver}" == "${version}" ]]; then
    new_pkgrel=$((old_pkgrel + 1))
else
    new_pkgrel=1
fi

sed -i "s/pkgrel=.*/pkgrel=${new_pkgrel}/" PKGBUILD
