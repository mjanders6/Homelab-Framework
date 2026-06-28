#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${ROOT_DIR}/scripts/lib/logging.sh"

log_info "Verifying Docker installation"
if ! command -v docker >/dev/null 2>&1; then
  log_error "Docker binary not found"
  exit 1
fi
log_info "Docker verification succeeded"
