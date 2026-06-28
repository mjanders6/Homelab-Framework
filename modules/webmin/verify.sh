#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${ROOT_DIR}/scripts/lib/logging.sh"

log_info "Verifying Webmin installation"
if ! command -v webmin >/dev/null 2>&1; then
  log_error "Webmin binary not found"
  exit 1
fi
log_info "Webmin verification succeeded"
