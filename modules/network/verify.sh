#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${ROOT_DIR}/scripts/lib/network.sh"
source "${ROOT_DIR}/scripts/lib/logging.sh"

log_info "Verifying network utilities"
require_ping 8.8.8.8
require_dns_resolution example.com
