#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${ROOT_DIR}/scripts/lib/logging.sh"

log_info "Verifying NFS service"
if ! systemctl is-active --quiet nfs-server; then
  log_error "NFS server service is not active"
  exit 1
fi
log_info "NFS verification succeeded"
