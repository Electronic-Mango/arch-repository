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

if grep -q "pkgver=${version}" "${pkgbuild_file}"; then
    echo "PKGBUILD is already up to date with version ${version}."
    exit 0
fi

cd "${packages_dir}/${package_name}"

sed -i "s/^pkgver=.*/pkgver=${version}/" PKGBUILD
sed -i "s/^sha256sums_x86_64=.*/sha256sums_x86_64=('${sha256hash}')/" PKGBUILD

# Use official .deb for tracking dependency changes
export pkgver="${version}"
deb_source_url="$(grep source_x86_64 PKGBUILD | awk -F'::' '{print $2}' | cut -d'"' -f1 | sed 's/linux-x64/linux-deb-x64/' | envsubst)"
temp_deb_dir="$(mktemp -d)"
pushd "${temp_deb_dir}"
echo "Downloading official .deb package from ${deb_source_url} ..."
wget -O "code_${version}.deb" -- "${deb_source_url}"
bsdtar -xf *.deb
find -type f -name "control.tar.xz" -exec bsdtar -xf {} \;
popd
find "${temp_deb_dir}" -type f -name "control" -exec cp {} . \;
