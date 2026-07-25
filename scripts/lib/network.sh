#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${SCRIPT_DIR}/error.sh"
source "${SCRIPT_DIR}/logging.sh"

require_network_interface() {
  local interface="${1:?require interface}"
  if ! ip link show "${interface}" >/dev/null 2>&1; then
    abort "Network interface not found: ${interface}"
  fi
  log_info "Network interface available: ${interface}"
}

require_ping() {
  local target="${1:?require target}"
  local count="${2:-3}"
  if ! ping -c "${count}" "${target}" >/dev/null 2>&1; then
    abort "Unable to ping ${target}"
  fi
  log_info "Ping succeeded: ${target}"
}

resolve_dns() {
  local host="${1:?require host}"
  local resolved
  resolved=$(getent hosts "${host}" | awk '{print $1}' | head -n1 || true)
  if [[ -z "${resolved}" ]]; then
    abort "DNS lookup failed for ${host}"
  fi
  printf '%s\n' "${resolved}"
}

require_dns_resolution() {
  local host="${1:?require host}"
  local resolved
  resolved=$(resolve_dns "${host}")
  log_info "Resolved ${host} to ${resolved}"
}

validate_ipv4() {
  local ip="${1:?require ip}"
  if ! [[ "${ip}" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    abort "Invalid IPv4 address: ${ip}"
  fi
}

check_tcp_port() {
  local host="${1:?require host}"
  local port="${2:?require port}"
  if ! timeout 3 bash -c "</dev/tcp/${host}/${port}" >/dev/null 2>&1; then
    abort "TCP port ${port} is closed on ${host}"
  fi
  log_info "TCP port ${port} is open on ${host}"
}
