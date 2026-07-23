#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

output=$(HOMELAB_ROLE=pi5 bash "${ROOT_DIR}/scripts/rebuild/rebuild-node.sh" --print-role)
if [[ "${output}" != "pi5" ]]; then
  echo "Expected pi5 role but got: ${output}" >&2
  exit 1
fi

echo "Role detection test passed"
