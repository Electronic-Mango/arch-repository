#!/usr/bin/env bash

set -euo pipefail

packages_dir="${1:-}"

if [[ ! -d "${packages_dir}" ]]; then
    echo "Packages directory not found: ${packages_dir}" >&2
    exit 1
fi

package_name="noctalia"

tmp_repo_dir="$(mktemp -d)"
pushd "${tmp_repo_dir}"
git clone https://gitlab.archlinux.org/archlinux/packaging/packages/noctalia.git .
rm -rf .gitignore .git/
popd

cd "${packages_dir}/${package_name}"
shopt -s dotglob
rm -rf -- ./*
cp -a "${tmp_repo_dir}"/. .
rm -rf "${tmp_repo_dir}"

if [[ $(tail -n 1 PKGBUILD) != "" ]]; then
    echo >> PKGBUILD
fi

if ! grep -q "^provides=" PKGBUILD; then
    echo "provides=('noctalia')" >> PKGBUILD
fi

if ! grep -q "^conflicts=" PKGBUILD; then
    echo "conflicts=('noctalia' 'noctalia-bin' 'noctalia-git' 'noctalia-shell' 'noctalia-meta')" >> PKGBUILD
fi
