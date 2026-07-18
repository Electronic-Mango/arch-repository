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

api_response=$(curl -sL --max-time 10 "${updates_api_url}")
version=$(echo "${api_response}" | jq -r '.tag_name')

if grep -q "_pkgver=${version}" PKGBUILD; then
    echo "PKGBUILD is already up to date with version ${version}."
    exit 0
fi

sha_url=$(echo "${api_response}" | jq -r --arg name "${version}.sha512sum" '.assets[] | select(.name == $name) | .browser_download_url')
sha512hash=$(curl -sL --max-time 10 "${sha_url}" | awk '{print $1}')

source PKGBUILD
old_version="${_pkgver}"
old_sha512hash="${sha512sums[0]}"

sed -i "s/${old_version}/${version}/g" PKGBUILD
sed -i "s/${old_sha512hash}/${sha512hash}/" PKGBUILD
sed -i "s/pkgrel=.*/pkgrel=1/" PKGBUILD

sed -i "s/${old_version}/${version}/g" .SRCINFO
sed -i "s/${old_sha512hash}/${sha512hash}/" .SRCINFO
sed -i "s/${old_version//-/_}/${version//-/_}/g" .SRCINFO
sed -i "s/pkgrel = .*/pkgrel = 1/" .SRCINFO
