#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${ROOT_DIR}/error.sh"
source "${ROOT_DIR}/logging.sh"
source "${ROOT_DIR}/modules.sh"

FRAMEWORK_STATE_DIR="${FRAMEWORK_STATE_DIR:-/var/lib/homelab}"
FRAMEWORK_LOG_DIR="${FRAMEWORK_LOG_DIR:-/var/log/homelab}"
FRAMEWORK_MODULE_DIR="${ROOT_DIR}/../modules"

ensure_framework_directories() {
  ensure_directory "${FRAMEWORK_STATE_DIR}"
  ensure_directory "${FRAMEWORK_LOG_DIR}"
}

framework_help() {
  local module
  printf '%s\n' "Available modules:"
  for module in $(list_modules); do
    printf '  - %s\n' "${module}"
  done
}

framework_status() {
  local module
  for module in $(list_modules); do
    if module_has_action "${module}" status; then
      run_module_action status "${module}"
    else
      log_warn "Module ${module} has no status action"
    fi
  done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  case "${1:-}" in
    framework_help)
      framework_help
      ;;
    framework_status)
      framework_status
      ;;
    *)
      printf 'Usage: %s <command>\n' "$(basename "$0")"
      printf 'Commands:\n'
      printf '  framework_help\n'
      printf '  framework_status\n'
      exit 1
      ;;
  esac
fi
