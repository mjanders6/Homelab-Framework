#!/usr/bin/env bash
set -euo pipefail

ROLLBACK_STACK=()

abort() {
  log_error "$*"
  exit 1
}

rollback_push() {
  ROLLBACK_STACK+=("$*")
}

rollback_run() {
  local exit_code="$1"
  if (( ${#ROLLBACK_STACK[@]} > 0 )); then
    log_warn "Running rollback handlers (${#ROLLBACK_STACK[@]})"
    local idx
    for (( idx=${#ROLLBACK_STACK[@]}-1; idx>=0; idx-- )); do
      local command="${ROLLBACK_STACK[idx]}"
      log_warn "Rollback: ${command}"
      bash -c "${command}" || log_error "Rollback command failed: ${command}"
    done
  fi
  return "$exit_code"
}

trap_error() {
  local code="$1"
  local line="$2"
  log_error "Error at line ${line}: exit ${code}"
  rollback_run "$code"
}

trap_exit() {
  local code="$?"
  if [[ "$code" -ne 0 ]]; then
    log_error "Script exited with status ${code}"
  fi
}

retry() {
  local attempts="${1:-3}"
  local delay="${2:-2}"
  shift 2
  local cmd=("$@")
  local count=0

  until "${cmd[@]}"; do
    count=$((count + 1))
    if (( count >= attempts )); then
      log_error "Retry failed after ${attempts} attempts: ${cmd[*]}"
      return 1
    fi
    log_warn "Attempt ${count}/${attempts} failed, retrying in ${delay}s"
    sleep "${delay}"
  done
}

setup_error_traps() {
  set -o errtrace
  trap 'trap_error $? ${LINENO}' ERR
  trap 'trap_exit' EXIT
}
