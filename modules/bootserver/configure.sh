#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${ROOT_DIR}/scripts/lib/logging.sh"
source "${ROOT_DIR}/scripts/lib/filesystem.sh"

BOOTSERVER_DIR="/opt/services/bootserver"
TFTP_ROOT="/srv/tftp"

ensure_directory "${BOOTSERVER_DIR}"
ensure_directory "${TFTP_ROOT}"
ensure_directory "${TFTP_ROOT}/boot"

if ! command -v docker >/dev/null 2>&1; then
  abort "Docker is required to configure bootserver"
fi

log_info "Starting bootserver containers via docker compose"
cd "${BOOTSERVER_DIR}"
docker compose up -d

log_info "Bootserver containers started"
