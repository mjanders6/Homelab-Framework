#!/usr/bin/env bash
set -euo pipefail
set -o igncr 2>/dev/null || true

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${ROOT_DIR}/scripts/lib/env.sh"

load_dotenv "${ROOT_DIR}/.env"
apply_network_defaults

INVENTORY="${ROOT_DIR}/ansible/inventories/lab/hosts.yml"
# Always use the repo config; Ansible ignores ansible.cfg found in world-writable dirs (e.g. WSL /mnt/c).
export ANSIBLE_CONFIG="${ROOT_DIR}/ansible.cfg"
PLAYBOOK_DIR="${ROOT_DIR}/ansible/playbooks"
EXTRA_VARS=()

usage() {
  cat <<'EOF'
Homelab Framework CLI

Usage:
  homelab-cli.sh                                   Interactive menu
  homelab-cli.sh run <playbook> --host <host> [options]
  homelab-cli.sh hosts                             List inventory hosts
  homelab-cli.sh playbooks                         List available playbooks
  homelab-cli.sh setup                             Install/verify Ansible on this command node
  homelab-cli.sh bootstrap                         Bootstrap this command node
  homelab-cli.sh help

Run options:
  --host, -H <host|group>   Host or group to action (required; use "all" for every host)
  --check                   Dry run (ansible --check)
  --ask-become-pass, -K     Prompt for the sudo password on the target
  --extra-vars, -e k=v      Extra Ansible variable (repeatable)
  --                        Pass remaining arguments straight to ansible-playbook

Example:
  homelab-cli.sh run bootstrap --host rpi1
EOF
}

die() { echo "ERROR: $*" >&2; exit 1; }

require_ansible() {
  command -v ansible-playbook >/dev/null 2>&1 || die "ansible-playbook not found. Run: homelab-cli.sh setup (Linux/WSL required; Ansible does not run on native Windows)."
}

setup_ansible() {
  case "$(uname -s)" in Linux) ;; *) die "Ansible needs a Linux control node (use Ubuntu, a Pi, or WSL)." ;; esac
  if ! command -v ansible-playbook >/dev/null 2>&1; then
    echo "Installing Ansible..."
    sudo apt-get update -y && sudo apt-get install -y ansible sshpass openssh-client
  fi
  ansible --version | head -n 1
  [[ -f "${HOME}/.ssh/id_ed25519" || -f "${HOME}/.ssh/id_rsa" ]] || echo "No SSH key found. Create one: ssh-keygen -t ed25519"
  echo "Next: ssh-copy-id <user>@<host> for each host, then: homelab-cli.sh run ping --host all"
}

list_hosts() {
  require_ansible
  ansible all -i "${INVENTORY}" --list-hosts | tail -n +2 | sed 's/^ *//'
}

list_playbooks() {
  local f
  for f in "${PLAYBOOK_DIR}"/*.yml; do
    [[ -e "${f}" ]] || continue
    basename "${f}" .yml
  done
}

run_playbook() {
  local playbook="${1:-}" host="" check=0 become=0 passthrough=()
  [[ -n "${playbook}" ]] || die "Playbook name required. See: homelab-cli.sh playbooks"
  shift
  playbook="${playbook%.yml}"
  [[ "${playbook}" =~ ^[A-Za-z0-9_-]+$ ]] || die "Invalid playbook name: ${playbook}"
  [[ -f "${PLAYBOOK_DIR}/${playbook}.yml" ]] || die "Unknown playbook '${playbook}'. Available: $(list_playbooks | paste -sd' ' -)"

  local extra=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --host|-H) [[ $# -ge 2 ]] || die "--host requires a value"; host="$2"; shift 2 ;;
      --check) check=1; shift ;;
      --ask-become-pass|-K) become=1; shift ;;
      --extra-vars|-e) [[ $# -ge 2 ]] || die "$1 requires a value"; extra+=("-e" "$2"); shift 2 ;;
      --) shift; passthrough=("$@"); break ;;
      *) die "Unknown option: $1" ;;
    esac
  done

  [[ -n "${host}" ]] || die "--host is required (use --host all for every host)"
  require_ansible
  ansible "${host}" -i "${INVENTORY}" --list-hosts >/dev/null 2>&1 || die "No inventory match for '${host}'. See: homelab-cli.sh hosts"

  local cmd=(ansible-playbook -i "${INVENTORY}" "${PLAYBOOK_DIR}/${playbook}.yml" --limit "${host}")
  [[ ${check} -eq 1 ]] && cmd+=(--check)
  [[ ${become} -eq 1 ]] && cmd+=(--ask-become-pass)
  [[ ${#EXTRA_VARS[@]} -gt 0 ]] && cmd+=("${EXTRA_VARS[@]}")
  [[ ${#extra[@]} -gt 0 ]] && cmd+=("${extra[@]}")
  [[ ${#passthrough[@]} -gt 0 ]] && cmd+=("${passthrough[@]}")

  echo "Running: ${cmd[*]}"
  "${cmd[@]}"
}

bootstrap_node() {
  echo "Bootstrapping this command node..."
  sudo bash "${ROOT_DIR}/scripts/bootstrap/bootstrap.sh"
}

pick() {
  local prompt="$1"; shift
  local choice
  PS3="${prompt} "
  select choice in "$@"; do
    if [[ -n "${choice}" ]]; then
      REPLY_VALUE="${choice}"
      return 0
    fi
    echo "Invalid selection. Try again."
  done
}

menu_run_playbook() {
  local hosts playbooks
  mapfile -t playbooks < <(list_playbooks)
  mapfile -t hosts < <(list_hosts)
  [[ ${#playbooks[@]} -gt 0 ]] || { echo "No playbooks found."; return; }
  hosts=(all "${hosts[@]}")
  pick "Playbook:" "${playbooks[@]}"; local playbook="${REPLY_VALUE}"
  pick "Host:" "${hosts[@]}"; local host="${REPLY_VALUE}"
  local check=()
  read -r -p "Dry run (--check)? [y/N]: " dry
  [[ "${dry,,}" == "y" ]] && check=(--check)
  run_playbook "${playbook}" --host "${host}" "${check[@]}"
}

menu_install_module() {
  local modules hosts
  mapfile -t modules < <(bash "${ROOT_DIR}/scripts/lib/modules.sh" list_modules)
  [[ ${#modules[@]} -gt 0 ]] || { echo "No modules available."; return; }
  mapfile -t hosts < <(list_hosts)
  pick "Module:" "${modules[@]}"; local module="${REPLY_VALUE}"
  pick "Host:" "${hosts[@]}"; local host="${REPLY_VALUE}"
  local target
  target="$(ansible-inventory -i "${INVENTORY}" --host "${host}" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("ansible_host",""))' 2>/dev/null || true)"
  target="${target:-${host}}"
  echo "Installing ${module} on ${host} (${target})..."
  ssh "${target}" "cd '${ROOT_DIR}' && sudo bash scripts/lib/modules.sh run install '${module}'"
}

set_env_variable() {
  read -r -p "Enter variable name: " key
  read -r -p "Enter value: " value
  [[ -n "${key}" ]] || { echo "Variable name cannot be empty."; return; }
  save_env_var "${ROOT_DIR}/.env" "${key}" "${value}" || { echo "Failed to save variable."; return; }
  export "${key}=${value}"
  EXTRA_VARS+=("-e" "${key}=${value}")
  echo "Saved ${key} to ${ROOT_DIR}/.env and added to this session."
}

print_current_env() {
  echo "NETWORK_GATEWAY=${NETWORK_GATEWAY:-}"
  echo "NETWORK_NAMESERVER=${NETWORK_NAMESERVER:-}"
  echo "NETWORK_PREFIX_LENGTH=${NETWORK_PREFIX_LENGTH:-}"
  echo "NETWORK_PROBE_IP=${NETWORK_PROBE_IP:-}"
}

menu() {
  while true; do
    cat <<'EOF'

HOMELAB FRAMEWORK CLI
1) Run Ansible playbook on a host
2) Install a module on a host
3) Bootstrap this command node
4) List hosts
5) Set environment variable
6) Print current environment
7) Exit
EOF
    read -r -p "Enter choice: " choice
    case "${choice}" in
      1) menu_run_playbook ;;
      2) menu_install_module ;;
      3) bootstrap_node ;;
      4) list_hosts ;;
      5) set_env_variable ;;
      6) print_current_env ;;
      7) echo "Goodbye."; exit 0 ;;
      *) echo "Invalid choice. Enter 1-7." ;;
    esac
  done
}

main() {
  case "${1:-menu}" in
    menu) menu ;;
    run) shift; run_playbook "$@" ;;
    hosts) list_hosts ;;
    playbooks) list_playbooks ;;
    setup) setup_ansible ;;
    bootstrap) bootstrap_node ;;
    help|-h|--help) usage ;;
    *) usage; exit 1 ;;
  esac
}

main "$@"