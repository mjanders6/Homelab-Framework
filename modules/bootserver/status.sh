#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${ROOT_DIR}/scripts/lib/logging.sh"

BOOTSERVER_DIR="/opt/services/bootserver"

if ! command -v docker >/dev/null 2>&1; then
  abort "Docker is required to check bootserver status"
fi

if [[ ! -f "${BOOTSERVER_DIR}/docker-compose.yml" ]]; then
  abort "Bootserver docker-compose file is missing: ${BOOTSERVER_DIR}/docker-compose.yml"
fi

log_info "Bootserver status"
docker compose -f "${BOOTSERVER_DIR}/docker-compose.yml" ps
