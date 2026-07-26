#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${ROOT_DIR}/scripts/lib/logging.sh"
source "${ROOT_DIR}/scripts/lib/error.sh"
source "${ROOT_DIR}/scripts/lib/filesystem.sh"
source "${ROOT_DIR}/scripts/lib/env.sh"

load_dotenv

SIYUAN_IMAGE="${SIYUAN_IMAGE:-b3log/siyuan:latest}"
SIYUAN_CONTAINER_NAME="${SIYUAN_CONTAINER_NAME:-siyuan}"
SIYUAN_PORT="${SIYUAN_PORT:-6806}"
SIYUAN_WORKSPACE_PATH="${SIYUAN_WORKSPACE_PATH:-/srv/samba/siyuan-workspace}"
SIYUAN_ACCESS_AUTH_CODE="${SIYUAN_ACCESS_AUTH_CODE:-}"

if [[ -z "${SIYUAN_ACCESS_AUTH_CODE}" ]]; then
  log_warn "SIYUAN_ACCESS_AUTH_CODE is not set in .env — fine for localhost only; set one before exposing this over Tailscale/LAN."
fi

log_info "Installing SiYuan (workspace=${SIYUAN_WORKSPACE_PATH}, port=${SIYUAN_PORT})"

if ! command -v docker >/dev/null 2>&1; then
  abort "docker is required — expected the 'docker' module dependency to have installed it."
fi
if ! docker compose version >/dev/null 2>&1; then
  abort "docker compose (v2 plugin) not found."
fi

ensure_directory "${SIYUAN_WORKSPACE_PATH}"

COMPOSE_DIR="/opt/homelab/siyuan"
COMPOSE_FILE="${COMPOSE_DIR}/docker-compose.yml"
ensure_directory "${COMPOSE_DIR}"

sed \
  -e "s|{{SIYUAN_IMAGE}}|${SIYUAN_IMAGE}|g" \
  -e "s|{{SIYUAN_CONTAINER_NAME}}|${SIYUAN_CONTAINER_NAME}|g" \
  -e "s|{{SIYUAN_PORT}}|${SIYUAN_PORT}|g" \
  -e "s|{{SIYUAN_WORKSPACE_PATH}}|${SIYUAN_WORKSPACE_PATH}|g" \
  -e "s|{{SIYUAN_ACCESS_AUTH_CODE}}|${SIYUAN_ACCESS_AUTH_CODE}|g" \
  "${SCRIPT_DIR}/templates/docker-compose.yml.tmpl" > "${COMPOSE_FILE}"

log_info "Rendered ${COMPOSE_FILE}"

docker compose -f "${COMPOSE_FILE}" up -d

log_info "SiYuan installation complete."
log_info "  Local URL: http://localhost:${SIYUAN_PORT}/"
log_info "  Run 'make configure-siyuan' next to wire up the Samba share."
