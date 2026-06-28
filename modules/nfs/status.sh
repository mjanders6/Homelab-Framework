#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${ROOT_DIR}/scripts/lib/logging.sh"

log_info "NFS module status"
if mountpoint -q /srv/nfs; then
  log_info "NFS export directory is mounted locally"
else
  log_warn "NFS export directory is not mounted locally"
fi
