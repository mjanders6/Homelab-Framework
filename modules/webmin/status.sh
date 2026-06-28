#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${ROOT_DIR}/scripts/lib/logging.sh"

log_info "Webmin module status"
if systemctl is-active --quiet webmin; then
  log_info "Webmin service is active"
else
  log_warn "Webmin service is not active"
fi
