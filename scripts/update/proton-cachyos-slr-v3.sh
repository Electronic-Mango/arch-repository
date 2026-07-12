#!/usr/bin/env bash

set -euo pipefail

packages_dir="${1:-}"

if [[ ! -d "${packages_dir}" ]]; then
    echo "Packages directory not found: ${packages_dir}" >&2
    exit 1
fi

package_name="proton-cachyos-slr-v3"

cd "${packages_dir}/${package_name}"
old_version=(
    "$(grep '^_srctag=' PKGBUILD)"
    "$(grep '^pkgver=' PKGBUILD)"
    "$(grep '^pkgrel=' PKGBUILD)"
    "$(grep '^epoch=' PKGBUILD || echo 'epoch=0')"
)

tmp_repo_dir="$(mktemp -d)"
pushd "${tmp_repo_dir}"
git clone --filter=blob:none --no-checkout https://github.com/CachyOS/CachyOS-PKGBUILDS.git .
git sparse-checkout init --no-cone
git sparse-checkout set "proton-cachyos-slr"
git checkout master
new_version=(
    "$(grep '^_srctag=' proton-cachyos-slr/PKGBUILD)"
    "$(grep '^pkgver=' proton-cachyos-slr/PKGBUILD)"
    "$(grep '^pkgrel=' proton-cachyos-slr/PKGBUILD)"
    "$(grep '^epoch=' proton-cachyos-slr/PKGBUILD || echo 'epoch=0')"
)
popd

if [[ "${old_version[@]}" == "${new_version[@]}" ]]; then
    echo "PKGBUILD is already up to date: ${old_version[@]}."
    rm -rf "${tmp_repo_dir}"
    exit 0
fi

cp -vfr "${tmp_repo_dir}/proton-cachyos-slr/." .

find_rule='/^build()[[:space:]]*{/,/^}/ {
    /^[[:space:]]*cd "\${_package_name}"$/a\
    find -type f -name "*.reg" -exec sed -i '\''s/"LogPixels"=dword:00000060/"LogPixels"=dword:000000c0/'\'' -- {} \\;
}'
sed -i \
    -e 's/-slr-x86_64/-slr-x86_64_v3/' \
    -e 's/s|##DISPLAY_NAME##|[^|]*|/s|##DISPLAY_NAME##|Proton CachyOS ${_srctag}|/' \
    -e "${find_rule}" \
    PKGBUILD

source './PKGBUILD'

echo "Checking BLAKE2 for: ${source[0]}"
new_b2_hash="$(curl -fsSL -- "${source[0]}" | b2sum | awk '{print $1}')"
echo "New BLAKE2: ${new_b2_hash}"

sed -i "s/^b2sums=('.*'/b2sums=('${new_b2_hash}'/" PKGBUILD

rm -rf "${tmp_repo_dir}"
