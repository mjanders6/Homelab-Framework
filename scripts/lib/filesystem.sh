#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${ROOT_DIR}/error.sh"
source "${ROOT_DIR}/logging.sh"

ensure_directory() {
  local path="${1:?require path}"
  if [[ -e "${path}" && ! -d "${path}" ]]; then
    abort "Path exists and is not a directory: ${path}"
  fi
  mkdir -p "${path}"
  chmod 0755 "${path}"
  log_debug "Ensured directory exists: ${path}"
}

require_free_space() {
  local mount_point="${1:-/}"
  local threshold_mb="${2:-1024}"
  local available_mb

  available_mb=$(df -Pm "${mount_point}" | awk 'NR==2 {print $4}')
  if (( available_mb < threshold_mb )); then
    abort "Insufficient free space on ${mount_point}: ${available_mb}MB available, ${threshold_mb}MB required"
  fi
  log_info "Free space check passed on ${mount_point}: ${available_mb}MB available"
}

check_disk_usage() {
  local target="${1:-/}"
  df -h "${target}"
}

validate_path() {
  local path="${1:?require path}"
  if [[ ! -e "${path}" ]]; then
    abort "Required path does not exist: ${path}"
  fi
}

ensure_mount() {
  local mount_point="${1:?require mount_point}"
  if ! mountpoint -q "${mount_point}"; then
    abort "Mount point is not mounted: ${mount_point}"
  fi
}
