#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${ROOT_DIR}/scripts/lib/logging.sh"
source "${ROOT_DIR}/scripts/lib/env.sh"

load_dotenv
apply_network_defaults

BOOTSERVER_NODE_NAMES="${BOOTSERVER_NODE_NAMES:-pi5 pi4_network pi4_monitor pi4_backup}"
BOOTSERVER_STATIC_IP_MAP_FILE="${BOOTSERVER_STATIC_IP_MAP_FILE:-${ROOT_DIR}/ansible/group_vars/bootserver_mac_ip_map.yml}"
INVENTORY_FILE="${ROOT_DIR}/ansible/inventories/bootserver.ini"
PLAYBOOK_FILE="${ROOT_DIR}/ansible/playbooks/bootserver.yml"

if ! command -v ansible-playbook >/dev/null 2>&1; then
  echo "ansible-playbook is required to build the Raspberry Pi golden image assets." >&2
  exit 1
fi

log_info "Generating node-specific boot assets for: ${BOOTSERVER_NODE_NAMES}"
log_info "Using static MAC/IP map file: ${BOOTSERVER_STATIC_IP_MAP_FILE}"
log_info "Network gateway=${NETWORK_GATEWAY} nameserver=${NETWORK_NAMESERVER} prefix=/${NETWORK_PREFIX_LENGTH}"
log_info "Node IPs: pi5=${PI5_IP} pi4_network=${PI4_NETWORK_IP} pi4_monitor=${PI4_MONITOR_IP} pi4_backup=${PI4_BACKUP_IP}"

ansible-playbook \
  -i "${INVENTORY_FILE}" \
  "${PLAYBOOK_FILE}" \
  --extra-vars "bootserver_node_names='${BOOTSERVER_NODE_NAMES}' bootserver_static_ip_map_file='${BOOTSERVER_STATIC_IP_MAP_FILE}'"
