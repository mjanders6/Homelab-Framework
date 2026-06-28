#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${ROOT_DIR}/scripts/lib/logging.sh"
source "${ROOT_DIR}/scripts/lib/packages.sh"

log_info "Installing K3s dependencies"
ensure_package curl
log_info "Installing K3s"
curl -sfL https://get.k3s.io | sh -
log_info "K3s installation complete"
