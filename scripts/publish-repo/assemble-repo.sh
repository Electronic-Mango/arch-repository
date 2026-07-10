#!/usr/bin/env bash

set -euo pipefail

artifacts_dir="${1:-}"
repo_dir="${2:-}"

if [[ -z "${artifacts_dir}" || -z "${repo_dir}" ]]; then
  echo "Usage: scripts/publish-repo/assemble-repo.sh <artifacts_dir> <repo_dir>" >&2
  exit 1
fi

if [[ ! -d "${artifacts_dir}" ]]; then
  echo "Artifacts directory not found: ${artifacts_dir}" >&2
  exit 1
fi

mkdir -p "${repo_dir}"
find "${artifacts_dir}" -type f -name '*.pkg.tar.*' -exec cp -v {} "${repo_dir}/" \;

pushd "${repo_dir}" >/dev/null
repo-add custom.db.tar.gz ./*.pkg.tar.*
cp -f custom.db.tar.gz custom.db
cp -f custom.files.tar.gz custom.files
popd >/dev/null
