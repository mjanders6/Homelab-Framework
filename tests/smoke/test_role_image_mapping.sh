#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

check_mapping() {
  local role="$1"
  local expected="$2"
  local actual

  actual=$(bash "${ROOT_DIR}/scripts/rebuild/role-image-map.sh" "${role}")
  if [[ "${actual}" != "${expected}" ]]; then
    echo "Expected ${role} -> ${expected}, got ${actual}" >&2
    exit 1
  fi
}

check_mapping "default" "ubuntu-24.04-server-amd64"
check_mapping "desktop" "ubuntu-24.04-server-amd64-desktop"
check_mapping "pi5" "ubuntu-24.04-server-arm64-raspi"
check_mapping "pi4_network" "ubuntu-24.04-server-arm64-raspi"

echo "Role image mapping test passed"
