#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${ROOT_DIR}/scripts/lib/logging.sh"

log_warn "The bootserver module is deprecated."
log_warn "Use the rebuild workflow instead: make rebuild-default, make rebuild-pi5, or make rebuild-desktop."
log_info "Bootserver installation steps are no longer part of the supported path."
