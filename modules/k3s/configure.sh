#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${ROOT_DIR}/scripts/lib/logging.sh"

log_info "Configuring K3s cluster settings"
# Add K3s cluster configuration and node join logic here
log_info "K3s configuration complete"
