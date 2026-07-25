#!/usr/bin/env bash
set -euo pipefail

ROLE="${1:-${HOMELAB_ROLE:-default}}"

case "${ROLE}" in
  default)
    echo "ubuntu-24.04-server-amd64"
    ;;
  desktop)
    echo "ubuntu-24.04-server-amd64-desktop"
    ;;
  pi5)
    echo "ubuntu-24.04-server-arm64-raspi"
    ;;
  pi4_network)
    echo "ubuntu-24.04-server-arm64-raspi"
    ;;
  pi4_monitor)
    echo "ubuntu-24.04-server-arm64-raspi"
    ;;
  pi4_backup)
    echo "ubuntu-24.04-server-arm64-raspi"
    ;;
  *)
    echo "Unknown role: ${ROLE}" >&2
    exit 1
    ;;
esac
