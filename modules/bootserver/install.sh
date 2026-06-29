#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${ROOT_DIR}/scripts/lib/logging.sh"
source "${ROOT_DIR}/scripts/lib/filesystem.sh"

BOOTSERVER_DIR="/opt/services/bootserver"
TFTP_ROOT="/srv/tftp"

ensure_directory "${BOOTSERVER_DIR}"
ensure_directory "${TFTP_ROOT}"
ensure_directory "${TFTP_ROOT}/boot"

log_info "Installing bootserver support directories"
cat > "${BOOTSERVER_DIR}/docker-compose.yml" <<'EOF'
version: '3.9'
services:
  tftp:
    image: atmoz/tftp
    container_name: homelab-boot-tftp
    restart: unless-stopped
    ports:
      - "69:69/udp"
    volumes:
      - /srv/tftp:/var/tftpboot:rw
    command: /usr/sbin/in.tftpd --foreground --verbose --address 0.0.0.0:69 /var/tftpboot

  nginx:
    image: nginx:stable-alpine
    container_name: homelab-boot-nginx
    restart: unless-stopped
    ports:
      - "80:80"
    volumes:
      - /srv/tftp:/usr/share/nginx/html:ro
      - ${BOOTSERVER_DIR}/nginx.conf:/etc/nginx/conf.d/default.conf:ro
EOF

cat > "${BOOTSERVER_DIR}/nginx.conf" <<'EOF'
server {
    listen 80 default_server;
    server_name _;

    root /usr/share/nginx/html;
    index index.html;

    location / {
        autoindex on;
    }
}
EOF

log_info "Creating per-node boot directories for Raspberry Pi nodes"
# Customize BOOTSERVER_NODE_NAMES before running install, e.g:
# export BOOTSERVER_NODE_NAMES="pi5 pi4_network pi4_monitor pi4_backup"
# or use comma-separated values:
# export BOOTSERVER_NODE_NAMES="pi5,pi4_network,pi4_monitor,pi4_backup"
BOOTSERVER_NODE_NAMES="${BOOTSERVER_NODE_NAMES:-pi5 pi4_network pi4_monitor pi4_backup}"
BOOTSERVER_NODE_NAMES="${BOOTSERVER_NODE_NAMES//,/ }"
read -r -a NODE_NAMES <<< "${BOOTSERVER_NODE_NAMES}"
log_info "Boot nodes: ${NODE_NAMES[*]}"

for node in "${NODE_NAMES[@]}"; do
  ensure_directory "${TFTP_ROOT}/boot/${node}"
  if [[ ! -f "${TFTP_ROOT}/boot/${node}/meta-data" ]]; then
    cat > "${TFTP_ROOT}/boot/${node}/meta-data" <<EOF
local-hostname: ${node}
instance-id: ${node}
EOF
  fi

  if [[ ! -f "${TFTP_ROOT}/boot/${node}/user-data" ]]; then
    cat > "${TFTP_ROOT}/boot/${node}/user-data" <<EOF
#cloud-config
users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys: []

runcmd:
  - [ sh, -c, 'echo "cloud-init completed on $(hostname)" > /var/log/cloud-init-complete.log' ]
EOF
  fi
done

log_info "Bootserver install artifacts generated at ${BOOTSERVER_DIR} and ${TFTP_ROOT}"
