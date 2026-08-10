#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# Load .env into the current shell (does not override existing exports).
# Precedence: existing environment > .env > callers' defaults.
load_dotenv() {
  local env_file="${1:-${ROOT_DIR}/.env}"
  local line key value

  if [[ ! -f "${env_file}" ]]; then
    return 0
  fi

  while IFS= read -r line || [[ -n "${line}" ]]; do
    line="${line%%#*}"
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "${line}" ]] && continue
    [[ "${line}" != *"="* ]] && continue

    key="${line%%=*}"
    value="${line#*=}"
    key="${key%"${key##*[![:space:]]}"}"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"

    if [[ "${value}" =~ ^\".*\"$ || "${value}" =~ ^\'.*\'$ ]]; then
      value="${value:1:-1}"
    fi

    if [[ -z "${!key+x}" ]]; then
      export "${key}=${value}"
    fi
  done < "${env_file}"
}

# Map node key (e.g. pi4_network) to env prefix (PI4_NETWORK).
node_env_prefix() {
  local node="${1:?node name required}"
  printf '%s\n' "${node}" | tr '[:lower:]' '[:upper:]'
}

node_mac_from_env() {
  local prefix var_name
  prefix="$(node_env_prefix "${1:?node name required}")"
  var_name="${prefix}_MAC"
  printf '%s\n' "${!var_name-}"
}

node_ip_from_env() {
  local prefix var_name
  prefix="$(node_env_prefix "${1:?node name required}")"
  var_name="${prefix}_IP"
  printf '%s\n' "${!var_name-}"
}

# Apply shared network defaults after load_dotenv (env / .env win).
apply_network_defaults() {
  export NETWORK_GATEWAY="${NETWORK_GATEWAY:-192.168.1.1}"
  export NETWORK_NAMESERVER="${NETWORK_NAMESERVER:-192.168.1.1}"
  export NETWORK_PREFIX_LENGTH="${NETWORK_PREFIX_LENGTH:-24}"
  export NETWORK_PROBE_IP="${NETWORK_PROBE_IP:-8.8.8.8}"
  export PI5_IP="${PI5_IP:-192.168.1.51}"
  export PI4_NETWORK_IP="${PI4_NETWORK_IP:-192.168.1.52}"
  export PI4_MONITOR_IP="${PI4_MONITOR_IP:-192.168.1.53}"
  export PI4_BACKUP_IP="${PI4_BACKUP_IP:-192.168.1.54}"
  export PI5_MAC="${PI5_MAC:-}"
  export PI4_NETWORK_MAC="${PI4_NETWORK_MAC:-}"
  export PI4_MONITOR_MAC="${PI4_MONITOR_MAC:-}"
  export PI4_BACKUP_MAC="${PI4_BACKUP_MAC:-}"
}
