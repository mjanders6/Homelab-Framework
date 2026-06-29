#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${ROOT_DIR}/scripts/lib/logging.sh"

BOOTSERVER_DIR="/opt/services/bootserver"
TFTP_ROOT="/srv/tftp"

if ! command -v docker >/dev/null 2>&1; then
  abort "Docker is required to verify bootserver"
fi

if [[ ! -f "${BOOTSERVER_DIR}/docker-compose.yml" ]]; then
  abort "Bootserver compose file is missing"
fi

log_info "Verifying bootserver configuration"
if ! docker compose -f "${BOOTSERVER_DIR}/docker-compose.yml" ps | grep -q 'homelab-boot-tftp\|homelab-boot-nginx'; then
  abort "Bootserver containers are not running"
fi

if [[ ! -d "${TFTP_ROOT}/boot" ]]; then
  abort "TFTP boot directory is missing: ${TFTP_ROOT}/boot"
fi

log_info "Bootserver verification succeeded"
