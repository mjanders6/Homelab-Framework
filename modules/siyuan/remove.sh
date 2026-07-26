#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${ROOT_DIR}/scripts/lib/logging.sh"
source "${ROOT_DIR}/scripts/lib/env.sh"

load_dotenv
SIYUAN_CONTAINER_NAME="${SIYUAN_CONTAINER_NAME:-siyuan}"
COMPOSE_FILE="/opt/homelab/siyuan/docker-compose.yml"

log_info "Removing SiYuan container"

if [[ -f "${COMPOSE_FILE}" ]]; then
  docker compose -f "${COMPOSE_FILE}" down --remove-orphans
else
  log_warn "Compose file not found at ${COMPOSE_FILE} — attempting direct container removal"
  docker rm -f "${SIYUAN_CONTAINER_NAME}" 2>/dev/null || true
fi

log_info "SiYuan container removed."
log_info "Workspace data and the Samba share entry in smb.conf were left in place intentionally — remove manually if desired."
