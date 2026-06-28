#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${ROOT_DIR}/scripts/lib/logging.sh"
source "${ROOT_DIR}/scripts/lib/filesystem.sh"

log_info "Filesystem module report"
printf "Data directory: %s\n" "${HOME_LAB_DATA_DIR:-/var/homelab/data}"
printf "Log directory: %s\n" "${HOME_LAB_LOG_DIR:-/var/log/homelab}"
check_disk_usage "/"
