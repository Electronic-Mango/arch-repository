#!/usr/bin/env bash

set -euo pipefail

packages_dir="${1:-}"

if [[ ! -d "${packages_dir}" ]]; then
    echo "Packages directory not found: ${packages_dir}" >&2
    exit 1
fi

package_name="umbriel-make-meta"

cd "${packages_dir}/${package_name}"

# Download PKGBUILD from the official repository
official_pkgbuild_url="https://raw.githubusercontent.com/CachyOS/CachyOS-PKGBUILDS/refs/heads/master/umbriel/umbriel/PKGBUILD"
official_pkgbuild="$(mktemp)"
if ! wget -O "${official_pkgbuild}" -- "${official_pkgbuild_url}"; then
    echo "Failed to download umbriel PKGBUILD from the official repository, skipping."
    exit 0
fi

# Update dependencies
awk -v q="'" '
FNR==NR {
    if (/^makedepends=\(/) inside=1
    if (inside) {
        if (block != "") block = block ORS
        block = block $0
    }
    if (inside && /\)[[:space:]]*$/) inside=0
    next
}

/^depends=\(/ {
    if (block !~ q "just" q) sub(/\n\)[[:space:]]*$/, "\n  " q "just" q "\n)", block)
    if (block !~ q "umbriel-meta" q) sub(/\n\)[[:space:]]*$/, "\n  " q "umbriel-meta" q "\n)", block)
    sub(/^makedepends=/, "depends=", block)
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

if git diff --quiet PKGBUILD; then
    echo "No changes to dependencies, skipping version bump."
    exit 0
fi

# Update versions
version=$(grep -Po "pkgver=\K.+" "${official_pkgbuild}")
release=$(grep -Po "pkgrel=\K.+" "${official_pkgbuild}")
sed -i "s/^pkgver=.*/pkgver=${version}/" PKGBUILD
sed -i "s/^pkgrel=.*/pkgrel=${release}/" PKGBUILD
