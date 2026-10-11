#!/usr/bin/env bash

set -euo pipefail

packages_dir="${1:-}"

if [[ ! -d "${packages_dir}" ]]; then
    echo "Packages directory not found: ${packages_dir}" >&2
    exit 1
fi

package_name="umbriel-meta"

cd "${packages_dir}/${package_name}"

# Download PKGBUILD from the official repository
official_pkgbuild_url="https://raw.githubusercontent.com/CachyOS/CachyOS-PKGBUILDS/refs/heads/master/umbriel/umbriel/PKGBUILD"
official_pkgbuild="$(mktemp)"
if ! wget -O "${official_pkgbuild}" -- "${official_pkgbuild_url}"; then
    echo "Failed to download umbriel PKGBUILD from the official repository, skipping."
    exit 0
fi

# Get previous version and release
prev_version=$(grep -Po "pkgver=\K.+" PKGBUILD)
prev_release=$(grep -Po "pkgrel=\K.+" PKGBUILD)

# Update versions
new_version=$(grep -Po "pkgver=\K.+" "${official_pkgbuild}")
new_release=$(grep -Po "pkgrel=\K.+" "${official_pkgbuild}")
sed -i "s/^pkgver=.*/pkgver=${new_version}/" PKGBUILD
sed -i "s/^pkgrel=.*/pkgrel=${new_release}/" PKGBUILD

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

if git diff --quiet -- PKGBUILD; then
    echo "No changes detected in PKGBUILD."
    exit 0
fi

# Bump release if new dependencies are detected butversion and release haven't changed
if [[ "${new_version}" == "${prev_version}" && "${new_release}" == "${prev_release}" ]]; then
    echo "No changes in version or release, bumping release."
    new_release=$((prev_release + 1))
    sed -i "s/^pkgrel=.*/pkgrel=${new_release}/" PKGBUILD
fi
