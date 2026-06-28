#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${ROOT_DIR}/scripts/lib/logging.sh"
source "${ROOT_DIR}/scripts/lib/filesystem.sh"

log_info "Configuring NFS exports"
ensure_directory "/srv/nfs"
# Add /etc/exports creation and exportfs commands here
log_info "NFS configuration complete"
