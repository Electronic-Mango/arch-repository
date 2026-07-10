#!/usr/bin/env bash

set -euo pipefail

scripts_dir="${1:-}"

if [[ ! -d "${scripts_dir}" ]]; then
    echo "Update scripts directory not found: ${scripts_dir}" >&2
    exit 1
fi

sudo apt-get update
sudo apt-get install -y jq

shopt -s nullglob
matrix_entries=()
for script in "${scripts_dir}"/*.sh; do
    matrix_entries+=("$(jq -n \
        --arg script_path "${script}" \
        --arg package_name "$(basename "${script%.sh}")" \
        '{script_path: $script_path, package_name: $package_name}')")
done

echo "${matrix_entries[*]}" | jq -c -s .
