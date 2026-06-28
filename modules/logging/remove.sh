#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../scripts/lib/logging.sh"
log_info "Logging core is a framework primitive and not removed by module remove"
