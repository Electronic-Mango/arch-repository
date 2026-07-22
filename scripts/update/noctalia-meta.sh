#!/usr/bin/env bash

set -euo pipefail

packages_dir="${1:-}"

if [[ ! -d "${packages_dir}" ]]; then
    echo "Packages directory not found: ${packages_dir}" >&2
    exit 1
fi

package_name="noctalia-meta"

cd "${packages_dir}/${package_name}"

# Download PKGBUILD from AUR
aur_pkgbuild_url="https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=noctalia-git"
aur_pkgbuild="$(mktemp)"
if ! wget -O "${aur_pkgbuild}" -- "${aur_pkgbuild_url}"; then
    echo "Failed to download noctalia-git PKGBUILD from AUR, skipping."
    exit 0
fi

# Update versions
version=$(grep -Po "pkgver=\K.+" "${aur_pkgbuild}")
release=$(grep -Po "pkgrel=\K.+" "${aur_pkgbuild}")
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
' "${aur_pkgbuild}" PKGBUILD | sponge PKGBUILD
