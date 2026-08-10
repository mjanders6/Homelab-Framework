#!/usr/bin/env bash
set -euo pipefail
set -o igncr 2>/dev/null || true

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# SCRIPT_DIR is e.g. <repo>/scripts/cli — go up two levels to reach repo root
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${ROOT_DIR}/scripts/lib/env.sh"

load_dotenv "${ROOT_DIR}/.env"
apply_network_defaults

COMMAND_NODE_ROLE="pi5"
EXTRA_VARS=()

print_header() {
  cat <<'EOF'
     __   __
       \ /
    |[o] [o]|
      { - }
        ||
        ||
   _____||______
  ||___    ____||
  ||}  |  |   {||
  ||   |  |    ||
  \\   |  |    //
   \\  |  |   //
    __ |__| __
    []      []
HOMELAB FRAMEWORK CLI - COMMAND NODE
-------------------------------------
A small friendly robot for rebuilds
EOF
}

print_menu() {
  echo
  echo "1) Bootstrap this command node"
  echo "2) Rebuild a remote server node"
  echo "3) Install a standalone module on a remote node"
  echo "4) Run Ansible playbook"
  echo "5) Set environment variable"
  echo "6) Print current environment"
  echo "7) Exit"
  echo
}

bootstrap_node() {
  echo "\n== Bootstrap ${COMMAND_NODE_ROLE} =="
  echo "Running shared bootstrap on the command node..."
  sudo bash "${ROOT_DIR}/scripts/bootstrap/bootstrap.sh"
}

node_hostname_to_role() {
  case "${1}" in
    rpi3-server) echo 'pi5' ;;
    rpi2-server) echo 'pi4_network' ;;
    rpi1-server) echo 'pi4_monitor' ;;
    rpi0-server) echo 'pi4_backup' ;;
    tower-server) echo 'desktop' ;;
    *) echo '' ;;
  esac
}

node_role_to_target() {
  case "${1}" in
    pi5) echo "${RPI3_SERVER_IP:-rpi3-server}" ;;
    pi4_network) echo "${RPI2_SERVER_IP:-rpi2-server}" ;;
    pi4_monitor) echo "${RPI1_SERVER_IP:-rpi1-server}" ;;
    pi4_backup) echo "${RPI0_SERVER_IP:-rpi0-server}" ;;
    desktop) echo "tower-server" ;;
    *) echo '' ;;
  esac
}

rebuild_node() {
  echo "\nSelect a remote server to rebuild:"
  select HOSTNAME in rpi3-server rpi2-server rpi1-server rpi0-server tower-server; do
    if [[ -n "${HOSTNAME}" ]]; then
      ROLE="$(node_hostname_to_role "${HOSTNAME}")"
      if [[ -z "${ROLE}" ]]; then
        echo "Unknown hostname selected. Try again."
        continue
      fi
      echo "\nRebuilding host: ${HOSTNAME} (role=${ROLE})"
      read -p "Dry run only? [y/N]: " dry
      if [[ "${dry,,}" == "y" ]]; then
        DRY_RUN=true HOMELAB_ROLE="${ROLE}" bash "${ROOT_DIR}/scripts/rebuild/rebuild-node.sh" --print-role
      else
        sudo HOMELAB_ROLE="${ROLE}" bash "${ROOT_DIR}/scripts/rebuild/rebuild-node.sh"
      fi
      break
    else
      echo "Invalid selection. Try again."
    fi
  done
}

install_module_on_node() {
  echo "\nAvailable modules:"
  mapfile -t MODULES < <(bash "${ROOT_DIR}/scripts/lib/modules.sh" list_modules)
  if [[ ${#MODULES[@]} -eq 0 ]]; then
    echo "No modules available."
    return
  fi

  select MODULE in "${MODULES[@]}"; do
    if [[ -n "${MODULE}" ]]; then
      echo "Selected module: ${MODULE}"
      break
    else
      echo "Invalid selection. Try again."
    fi
  done

  echo "\nSelect a target host:"
  select HOSTNAME in rpi3-server rpi2-server rpi1-server rpi0-server tower-server; do
    if [[ -n "${HOSTNAME}" ]]; then
      ROLE="$(node_hostname_to_role "${HOSTNAME}")"
      if [[ -z "${ROLE}" ]]; then
        echo "Unknown hostname selected. Try again."
        continue
      fi
      TARGET="$(node_role_to_target "${ROLE}")"
      if [[ -z "${TARGET}" ]]; then
        echo "No target address available for ${HOSTNAME}."
        return
      fi
      echo "\nInstalling ${MODULE} on ${HOSTNAME} (${TARGET})..."
      if [[ "${TARGET}" =~ ^(localhost|127\.0\.0\.1)$ ]]; then
        sudo bash "${ROOT_DIR}/scripts/lib/modules.sh" run install "${MODULE}"
      else
        ssh "${TARGET}" "cd '${ROOT_DIR}' && sudo bash scripts/lib/modules.sh run install '${MODULE}'"
      fi
      break
    else
      echo "Invalid selection. Try again."
    fi
  done
}

run_ansible_playbook() {
  echo "\nAvailable playbooks:"
  select playbook in bootstrap desktop infrastructure; do
    if [[ -n "${playbook}" ]]; then
      echo "\nRunning ansible-playbook for ${playbook}..."
      ansible-playbook -i localhost, "${ROOT_DIR}/ansible/playbooks/${playbook}.yml" "${EXTRA_VARS[@]}"
      break
    else
      echo "Invalid selection. Try again."
    fi
  done
}

set_env_variable() {
  read -p "Enter variable name: " key
  read -p "Enter value: " value
  if [[ -z "${key}" ]]; then
    echo "Variable name cannot be empty."
    return
  fi
  EXTRA_VARS+=("-e" "${key}=${value}")
  echo "Added extra var: ${key}=${value}"
}

print_current_env() {
  echo "\nCurrent environment variables (from .env and defaults):"
  echo "NETWORK_GATEWAY=${NETWORK_GATEWAY}"
  echo "NETWORK_NAMESERVER=${NETWORK_NAMESERVER}"
  echo "NETWORK_PREFIX_LENGTH=${NETWORK_PREFIX_LENGTH}"
  echo "NETWORK_PROBE_IP=${NETWORK_PROBE_IP}"
  echo "RPI3_SERVER_IP=${RPI3_SERVER_IP}"
  echo "RPI3_SERVER_MAC=${RPI3_SERVER_MAC}"
  echo "RPI2_SERVER_IP=${RPI2_SERVER_IP}"
  echo "RPI2_SERVER_MAC=${RPI2_SERVER_MAC}"
  echo "RPI1_SERVER_IP=${RPI1_SERVER_IP}"
  echo "RPI1_SERVER_MAC=${RPI1_SERVER_MAC}"
  echo "RPI0_SERVER_IP=${RPI0_SERVER_IP}"
  echo "RPI0_SERVER_MAC=${RPI0_SERVER_MAC}"
}

main() {
  print_header
  while true; do
    print_menu
    read -p "Enter choice: " choice
    case "${choice}" in
      1) bootstrap_node ;; 
      2) rebuild_node ;; 
      3) install_module_on_node ;; 
      4) run_ansible_playbook ;; 
      5) set_env_variable ;; 
      6) print_current_env ;; 
      7) echo "Goodbye."; exit 0 ;; 
      *) echo "Invalid choice. Enter 1-7." ;; 
    esac
  done
}

main "$@"

