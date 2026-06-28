#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${ROOT_DIR}/scripts/lib/logging.sh"
source "${ROOT_DIR}/scripts/lib/filesystem.sh"

log_info "Verifying filesystem helpers"
require_free_space "/" 1024
log_info "Filesystem verification completed successfully"
