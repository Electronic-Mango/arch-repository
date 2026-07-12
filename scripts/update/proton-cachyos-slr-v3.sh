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
    exit 0
fi

cp -vfr "${tmp_repo_dir}/proton-cachyos-slr/." .

mv proton-cachyos-slr.install proton-cachyos-slr-v3.install

source './PKGBUILD'

download_source_index=0
old_source_url=""
for i in "${!source[@]}"; do
    old_source_url="${source[${i}]}"
    if [[ "${old_source_url}" == *"proton-cachyos/releases/download"* ]]; then
        download_source_index="${i}"
        break
    fi
done
old_b2hash="${b2sums[${download_source_index}]}"

find_rule='/^build()[[:space:]]*{/,/^}/ {
    /^[[:space:]]*cd "\${_package_name}"$/a\
    find -type f -name "*.reg" -exec sed -i '\''s/"LogPixels"=dword:00000060/"LogPixels"=dword:000000c0/'\'' -- {} \\;
}'
sed -i \
    -e 's/pkgname=proton-cachyos-slr/pkgname=proton-cachyos-slr-v3/' \
    -e 's/-slr-x86_64/-slr-x86_64_v3/' \
    -e 's/s|##DISPLAY_NAME##|[^|]*|/s|##DISPLAY_NAME##|Proton CachyOS ${_srctag}|/' \
    -e "${find_rule}" \
    PKGBUILD

source './PKGBUILD'

new_source_url="${source[${download_source_index}]}"
echo "Checking new BLAKE2 for v3: ${new_source_url}"
new_b2hash="$(curl -fsSL -- "${new_source_url}" | b2sum | awk '{print $1}')"

sed -i "s/${old_b2hash}/${new_b2hash}/" PKGBUILD

sed -i \
    -e 's/ = proton-cachyos-slr/ = proton-cachyos-slr-v3/' \
    -e "s/${old_b2hash}/${new_b2hash}/" \
    -e "s/${old_source_url}/${new_source_url}/" \
    .SRCINFO