#!/usr/bin/env bash

set -euo pipefail

packages_dir="${1:-}"

if [[ ! -d "${packages_dir}" ]]; then
    echo "Packages directory not found: ${packages_dir}" >&2
    exit 1
fi

package_name="xwayland-satellite-git-cursor-scaling-fix"

tmp_repo_dir="$(mktemp -d)"
pushd "${tmp_repo_dir}"
git clone https://github.com/Electronic-Mango/xwayland-satellite-package.git .
git remote add upstream https://gitlab.archlinux.org/archlinux/packaging/packages/xwayland-satellite.git
git fetch --all
git rebase upstream/main
makepkg --nobuild --nodeps --noprepare
git clean -ffxd
popd

cd "${packages_dir}/${package_name}"
shopt -s dotglob
cp -a "${tmp_repo_dir}"/. .
rm -rf "${tmp_repo_dir}"
