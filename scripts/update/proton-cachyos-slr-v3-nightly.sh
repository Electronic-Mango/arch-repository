#!/usr/bin/env bash

set -euo pipefail

packages_dir="${1:-}"

if [[ ! -d "${packages_dir}" ]]; then
    echo "Packages directory not found: ${packages_dir}" >&2
    exit 1
fi

package_name="proton-cachyos-slr-v3-nightly"

cd "${packages_dir}/${package_name}"

current_date=$(date -u +%F)
if [[ -f 'updated' && grep -q "${current_date}" updated ]]; then
    echo 'Already updated today.'
    exit 0
fi
echo "${current_date}" > updated

auth_header=()
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    auth_header=("-H" "Authorization: Bearer ${GITHUB_TOKEN}")
fi

workflow_runs_api_url='https://api.github.com/repos/CachyOS/proton-cachyos/actions/workflows/snapshot.yml/runs?status=success&per_page=1'
workflow_runs_api_response=$(curl -sL --max-time 10 "${auth_header[@]}" "${workflow_runs_api_url}")
workflow_id=$(grep -Po '^      "id": \d+,$' <<< "${workflow_runs_api_response}" | grep -Po '\d+')
if [[ -z "${workflow_id}" ]]; then
    echo 'Failed to retrieve the latest workflow run ID.'
    exit 1
fi

workflow_artifacts_api_url="https://api.github.com/repos/CachyOS/proton-cachyos/actions/runs/${workflow_id}/artifacts"
workflow_artifacts_response=$(curl -sL --max-time 10 "${auth_header[@]}" "${workflow_artifacts_api_url}")

if ! selected="$(jq -ec '
    [.artifacts[] | select(.name | test("-x86_64_v3\\.(tar\\.xz|sha512sum)$"))]
    | (map(select(.name | endswith(".tar.xz"))) | max_by(.created_at)) as $tar
    | (map(select(.name | endswith(".sha512sum"))) | max_by(.created_at)) as $sha
    | select($tar != null and $sha != null)
    | [$tar.id, $tar.name, ($tar.digest | ltrimstr("sha256:")), $sha.id, $sha.name, ($sha.digest | ltrimstr("sha256:"))]
    | select(all(. != null and . != ""))
' <<< "${workflow_artifacts_response}")"; then
    echo "Failed to find x86_64_v3 artifacts in workflow run ${workflow_id}."
    exit 1
fi

{
    read -r proton_id
    read -r proton_name
    read -r proton_digest
    read -r sha_id
    read -r sha_name
    read -r sha_digest
} < <(jq -r '.[]' <<< "${selected}")

base_name="${proton_name%.tar.xz}"
if [[ "${base_name}" != "${sha_name%.sha512sum}" ]]; then
    echo "Artifact names do not match: ${proton_name}, ${sha_name}"
    exit 1
fi

name_regex='^proton-cachyos-([0-9.]+-[0-9]+)-[^-]+-([0-9]+)-(g[0-9a-f]+)-x86_64_v3$'
if [[ ! "${base_name}" =~ ${name_regex} ]]; then
    echo "Unexpected artifact name format: ${base_name}"
    exit 1
fi

base_version="${BASH_REMATCH[1]}"
build_number="${BASH_REMATCH[2]}"
commit_hash="${BASH_REMATCH[3]}"

sed -i "s/_main_pkgver=.*/_main_pkgver=${base_version}/" PKGBUILD
sed -i "s/_build_number=.*/_build_number=${build_number}/" PKGBUILD
sed -i "s/_commit_hash=.*/_commit_hash=${commit_hash}/" PKGBUILD
sed -i "s/_proton_artifact_id=.*/_proton_artifact_id=${proton_id}/" PKGBUILD
sed -i "s/_checksum_artifact_id=.*/_checksum_artifact_id=${sha_id}/" PKGBUILD
sed -i "s/_proton_zip_checksum=.*/_proton_zip_checksum=${proton_digest}/" PKGBUILD
sed -i "s/_checksum_zip_checksum=.*/_checksum_zip_checksum=${sha_digest}/" PKGBUILD
