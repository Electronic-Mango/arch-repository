#!/usr/bin/env bash

set -euo pipefail

packages_dir="${1:-}"

if [[ ! -d "${packages_dir}" ]]; then
    echo "Packages directory not found: ${packages_dir}" >&2
    exit 1
fi

package_name="noctalia-meta"

cd "${packages_dir}/${package_name}"

# Download PKGBUILD from the official repository
official_pkgbuild_url="https://gitlab.archlinux.org/archlinux/packaging/packages/noctalia/-/raw/main/PKGBUILD?inline=false"
official_pkgbuild="$(mktemp)"
if ! wget -O "${official_pkgbuild}" -- "${official_pkgbuild_url}"; then
    echo "Failed to download noctalia PKGBUILD, skipping."
    exit 0
fi

# Update versions
version=$(grep -Po "pkgver=\K.+" "${official_pkgbuild}")
release=$(grep -Po "pkgrel=\K.+" "${official_pkgbuild}")
sed -i "s/^pkgver=.*/pkgver=${version}/" PKGBUILD
sed -i "s/^pkgrel=.*/pkgrel=${release}/" PKGBUILD

# Update dependencies
awk '
FNR==NR {
    if (/^depends=\(/) inside=1
    if (inside) {
        if (block != "") block = block ORS
        block = block $0
    }
    if (inside && /\)[[:space:]]*$/) inside=0
    next
}

/^depends=\(/ {
    printf "%s\n", block
    skip=1
    next
}

skip {
    if (/\)[[:space:]]*$/) skip=0
    next
}

{ print }
' "${official_pkgbuild}" PKGBUILD | sponge PKGBUILD
