#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${ROOT_DIR}/scripts/lib/logging.sh"
source "${ROOT_DIR}/scripts/lib/filesystem.sh"

log_info "Installing filesystem helpers"
ensure_directory "${HOME_LAB_DATA_DIR:-/var/homelab/data}"
ensure_directory "${HOME_LAB_LOG_DIR:-/var/log/homelab}"
log_info "Filesystem helpers are installed and ready"
