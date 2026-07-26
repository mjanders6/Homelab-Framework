#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${ROOT_DIR}/scripts/lib/logging.sh"
source "${ROOT_DIR}/scripts/lib/env.sh"

load_dotenv
SIYUAN_PORT="${SIYUAN_PORT:-6806}"
SIYUAN_CONTAINER_NAME="${SIYUAN_CONTAINER_NAME:-siyuan}"

log_info "Verifying SiYuan installation"

if ! docker ps --filter "name=${SIYUAN_CONTAINER_NAME}" --filter status=running --format '{{.Names}}' | grep -q "^${SIYUAN_CONTAINER_NAME}$"; then
  log_error "SiYuan container '${SIYUAN_CONTAINER_NAME}' is not running"
  exit 1
fi

if ! curl -fsS -o /dev/null "http://localhost:${SIYUAN_PORT}/"; then
  log_error "SiYuan web UI not reachable on port ${SIYUAN_PORT}"
  exit 1
fi

log_info "SiYuan verification succeeded"
