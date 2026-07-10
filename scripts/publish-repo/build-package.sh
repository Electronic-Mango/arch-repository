#!/usr/bin/env bash

set -euo pipefail

package_dir="${1:-}"
output_dir="${2:-}"
gpg_key_id="${3:-}"

if [[ -z "${package_dir}" || -z "${output_dir}" || -z "${gpg_key_id}" ]]; then
  echo "Usage: scripts/publish-repo/build-package.sh <package_dir> <output_dir> <gpg_key_id>" >&2
  exit 1
fi

if [[ ! -f "${package_dir}/PKGBUILD" ]]; then
  echo "PKGBUILD not found in: ${package_dir}" >&2
  exit 1
fi

mkdir -p "${output_dir}"

pushd "${package_dir}" >/dev/null
makepkg -sf --sign --key "${gpg_key_id}" --noconfirm --needed
namcap PKGBUILD || true
find . -maxdepth 1 -type f -name '*.pkg.tar.*' -not -name '*.sig' -exec namcap {} \; || true
find . -maxdepth 1 -type f -name '*.pkg.tar.*' -exec cp -v {} "${output_dir}/" \;
popd >/dev/null
