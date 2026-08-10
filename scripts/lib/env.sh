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
  local host_prefix legacy_prefix var_name
  host_prefix="$(node_host_prefix "${1:?node name required}")"
  var_name="${host_prefix}_MAC"
  if [[ -n "${!var_name-}" ]]; then
    printf '%s\n' "${!var_name}"
    return 0
  fi
  legacy_prefix="$(node_env_prefix "${1}")"
  var_name="${legacy_prefix}_MAC"
  printf '%s\n' "${!var_name-}"
}

node_ip_from_env() {
  local prefix var_name
  local host_prefix legacy_prefix var_name
  host_prefix="$(node_host_prefix "${1:?node name required}")"
  var_name="${host_prefix}_IP"
  if [[ -n "${!var_name-}" ]]; then
    printf '%s\n' "${!var_name}"
    return 0
  fi
  legacy_prefix="$(node_env_prefix "${1}")"
  var_name="${legacy_prefix}_IP"
  printf '%s\n' "${!var_name-}"
}

# Map node names (pi5, pi4_network, ...) to host-style env prefixes.
node_host_prefix() {
  local node="${1:?node name required}"
  case "${node}" in
    pi5) echo 'RPI3_SERVER' ;;
    pi4_network) echo 'RPI2_SERVER' ;;
    pi4_monitor) echo 'RPI1_SERVER' ;;
    pi4_backup) echo 'RPI0_SERVER' ;;
    *) node_env_prefix "${node}" ;;
  esac
}
# Apply shared network defaults after load_dotenv (env / .env win).
apply_network_defaults() {
  # Network values are intentionally left unset here so callers must provide
  # them via the environment or `.env`. No hard-coded IP or MAC defaults.
  export NETWORK_GATEWAY="${NETWORK_GATEWAY:-}"
  export NETWORK_NAMESERVER="${NETWORK_NAMESERVER:-}"
  export NETWORK_PREFIX_LENGTH="${NETWORK_PREFIX_LENGTH:-24}"
  export NETWORK_PROBE_IP="${NETWORK_PROBE_IP:-}"

  # Export host-style RPI*_SERVER_* variables — no legacy PI* fallbacks.
  export RPI3_SERVER_IP="${RPI3_SERVER_IP:-}"
  export RPI2_SERVER_IP="${RPI2_SERVER_IP:-}"
  export RPI1_SERVER_IP="${RPI1_SERVER_IP:-}"
  export RPI0_SERVER_IP="${RPI0_SERVER_IP:-}"
  export RPI3_SERVER_MAC="${RPI3_SERVER_MAC:-}"
  export RPI2_SERVER_MAC="${RPI2_SERVER_MAC:-}"
  export RPI1_SERVER_MAC="${RPI1_SERVER_MAC:-}"
  export RPI0_SERVER_MAC="${RPI0_SERVER_MAC:-}"
}

# Validate presence of required environment variables at runtime.
# Set SKIP_ENV_VALIDATION=1 in the environment to bypass this check.
validate_required_env() {
  if [[ "${SKIP_ENV_VALIDATION:-}" == "1" || "${SKIP_ENV_VALIDATION:-}" == "true" ]]; then
    return 0
  fi

  local required=(
    NETWORK_GATEWAY
    NETWORK_NAMESERVER
    NETWORK_PROBE_IP
    RPI3_SERVER_IP
    RPI2_SERVER_IP
    RPI1_SERVER_IP
    RPI0_SERVER_IP
    RPI3_SERVER_MAC
    RPI2_SERVER_MAC
    RPI1_SERVER_MAC
    RPI0_SERVER_MAC
  )

  local missing=()
  for v in "${required[@]}"; do
    if [[ -z "${!v:-}" ]]; then
      missing+=("$v")
    fi
  done

  if [[ ${#missing[@]} -ne 0 ]]; then
    echo "" >&2
    echo "ERROR: Required environment variables are missing:" >&2
    for m in "${missing[@]}"; do echo "  - $m" >&2; done
    echo "" >&2
    echo "Create a .env file from .env.example or export these variables before running the scripts." >&2
    echo "See docs/installation/INSTALL.md for guidance." >&2
    exit 1
  fi
}


