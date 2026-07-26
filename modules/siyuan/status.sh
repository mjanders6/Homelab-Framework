#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${ROOT_DIR}/scripts/lib/logging.sh"
source "${ROOT_DIR}/scripts/lib/env.sh"

load_dotenv
SIYUAN_CONTAINER_NAME="${SIYUAN_CONTAINER_NAME:-siyuan}"
SAMBA_SHARE_NAME="${SAMBA_SHARE_NAME:-siyuan-workspace}"

log_info "SiYuan module status"

if docker ps --filter "name=${SIYUAN_CONTAINER_NAME}" --filter status=running --format '{{.Names}}' | grep -q "^${SIYUAN_CONTAINER_NAME}$"; then
  log_info "Container is running"
else
  log_warn "Container is not running"
fi

if smbclient -L localhost -U % 2>/dev/null | grep -qi "${SAMBA_SHARE_NAME}"; then
  log_info "Samba share is visible"
else
  log_warn "Samba share not visible — check /etc/samba/smb.conf and that smbd is running"
fi
