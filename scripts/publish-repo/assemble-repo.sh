#!/usr/bin/env bash

set -euo pipefail

artifacts_dir="${1:-}"
repo_dir="${2:-}"
gpg_key_id="${3:-}"

if [[ -z "${artifacts_dir}" || -z "${repo_dir}" || -z "${gpg_key_id}" ]]; then
  echo "Usage: scripts/publish-repo/assemble-repo.sh <artifacts_dir> <repo_dir> <gpg_key_id>" >&2
  exit 1
fi

if [[ ! -d "${artifacts_dir}" ]]; then
  echo "Artifacts directory not found: ${artifacts_dir}" >&2
  exit 1
fi

mkdir -p "${repo_dir}"
find "${artifacts_dir}" -type f -name '*.pkg.tar.*' -exec cp -v {} "${repo_dir}/" \;

pushd "${repo_dir}" >/dev/null
mapfile -t package_files < <(find . -maxdepth 1 -type f -name '*.pkg.tar.*' -not -name '*.sig' | sort)

if [[ ${#package_files[@]} -eq 0 ]]; then
  echo "No package archives found in: ${repo_dir}" >&2
  exit 1
fi

repo-add --sign --key "${gpg_key_id}" electronic-mango.db.tar.gz "${package_files[@]}"
rm -f electronic-mango.db electronic-mango.files electronic-mango.db.sig electronic-mango.files.sig
cp -f electronic-mango.db.tar.gz electronic-mango.db
cp -f electronic-mango.files.tar.gz electronic-mango.files
cp -f electronic-mango.db.tar.gz.sig electronic-mango.db.sig
cp -f electronic-mango.files.tar.gz.sig electronic-mango.files.sig
popd >/dev/null
