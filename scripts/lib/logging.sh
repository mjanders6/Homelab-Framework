#!/usr/bin/env bash
set -euo pipefail

LOG_LEVEL="${LOG_LEVEL:-info}"

log_level_to_int() {
  case "${1:-info}" in
    debug) echo 0 ;;
    info) echo 1 ;;
    warn|warning) echo 2 ;;
    error) echo 3 ;;
    *) echo 1 ;;
  esac
}

_log() {
  local level="$1"; shift
  local message="$*"
  local level_value
  local configured_value

  level_value="$(log_level_to_int "$level")"
  configured_value="$(log_level_to_int "$LOG_LEVEL")"

  if (( level_value >= configured_value )); then
    printf '%s [%s] %s\n' "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" "${level^^}" "$message"
  fi
}

log_debug() { _log debug "$*"; }
log_info()  { _log info "$*"; }
log_warn()  { _log warn "$*"; }
log_error() { _log error "$*" >&2; }

set_log_level() {
  LOG_LEVEL="${1:-info}"
}
