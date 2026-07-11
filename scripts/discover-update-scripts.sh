#!/usr/bin/env bash

set -euo pipefail

scripts_dir="${1:-}"

if [[ ! -d "${scripts_dir}" ]]; then
    echo "Update scripts directory not found: ${scripts_dir}" >&2
    exit 1
fi

for script in "${scripts_dir}"/*.sh; do
    jq -n --arg script_path "${script}" --arg package_name "$(basename "${script%.sh}")" \
        '{script_path: $script_path, package_name: $package_name}'
done | jq -cs .
