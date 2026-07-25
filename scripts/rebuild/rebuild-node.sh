#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

cd "${ROOT_DIR}"

ROLE="${1:-${HOMELAB_ROLE:-default}}"
ROLE_IMAGE_MAP_SCRIPT="${ROOT_DIR}/scripts/rebuild/role-image-map.sh"
DRY_RUN="${DRY_RUN:-false}"
PRINT_ROLE="false"

if [[ "${ROLE}" == "--print-role" ]]; then
  PRINT_ROLE="true"
  ROLE="${HOMELAB_ROLE:-default}"
fi

if [[ $(id -u) -ne 0 ]]; then
  if [[ "${DRY_RUN}" =~ ^(yes|true|1)$ ]] || [[ "${PRINT_ROLE}" == "true" ]]; then
    echo "[DRY-RUN] Running as non-root; skipping privilege check."
  else
    echo "[ERROR] rebuild-node.sh must be run as root or with sudo"
    exit 1
  fi
fi


if [[ "${ROLE}" == "--print-role" ]]; then
  PRINT_ROLE="true"
  ROLE="${HOMELAB_ROLE:-default}"
fi

run_script() {
  local script_path="$1"
  if [[ "${DRY_RUN}" =~ ^(yes|true|1)$ ]]; then
    echo "[DRY-RUN] bash ${script_path}"
  else
    bash "${script_path}"
  fi
}

case "${ROLE}" in
  default)
    echo "Starting standard rebuild flow..."
    ;;
  auto)
    echo "Resolving role automatically from environment..."
    ;;
  desktop)
    echo "Starting desktop rebuild flow..."
    ;;
  pi5)
    echo "Starting Pi 5 rebuild flow..."
    ;;
  pi4_network)
    echo "Starting Pi 4 networking rebuild flow..."
    ;;
  pi4_monitor)
    echo "Starting Pi 4 monitoring rebuild flow..."
    ;;
  pi4_backup)
    echo "Starting Pi 4 backup rebuild flow..."
    ;;
  *)
    echo "Unknown role: ${ROLE}"
    echo "Supported roles: default, desktop, pi5, pi4_network, pi4_monitor, pi4_backup"
    exit 1
    ;;
esac

if [[ "${PRINT_ROLE}" == "true" ]]; then
  echo "${ROLE}"
  exit 0
fi

IMAGE_NAME="$(bash "${ROLE_IMAGE_MAP_SCRIPT}" "${ROLE}")"
echo "Resolved image for role ${ROLE}: ${IMAGE_NAME}"

echo "Running bootstrap..."
run_script "${ROOT_DIR}/scripts/bootstrap/bootstrap.sh"

echo "Running shared base setup..."
run_script "${ROOT_DIR}/scripts/install/common_packages.sh"
run_script "${ROOT_DIR}/scripts/configure/setup_directories.sh"

echo "Running role-specific setup..."
case "${ROLE}" in
  desktop)
    run_script "${ROOT_DIR}/scripts/install/install_samba.sh"
    run_script "${ROOT_DIR}/scripts/configure/configure_samba_shares.sh"
    run_script "${ROOT_DIR}/scripts/install/install_webmin.sh"
    ;;
  pi5)
    run_script "${ROOT_DIR}/scripts/install/install_docker.sh"
    run_script "${ROOT_DIR}/scripts/install/install_cockpit.sh"
    run_script "${ROOT_DIR}/scripts/install/install_ansible.sh"
    run_script "${ROOT_DIR}/scripts/configure/setup_ansible_directories.sh"
    ;;
  pi4_network)
    run_script "${ROOT_DIR}/scripts/install/install_docker.sh"
    run_script "${ROOT_DIR}/scripts/install/install_tailscale.sh"
    run_script "${ROOT_DIR}/scripts/install/install_cockpit.sh"
    ;;
  pi4_monitor)
    run_script "${ROOT_DIR}/scripts/install/install_docker.sh"
    run_script "${ROOT_DIR}/scripts/install/install_node_exporter.sh"
    run_script "${ROOT_DIR}/scripts/install/install_cockpit.sh"
    ;;
  pi4_backup)
    run_script "${ROOT_DIR}/scripts/install/install_docker.sh"
    run_script "${ROOT_DIR}/scripts/install/install_restic.sh"
    run_script "${ROOT_DIR}/scripts/install/install_samba.sh"
    run_script "${ROOT_DIR}/scripts/configure/configure_samba_shares.sh"
    run_script "${ROOT_DIR}/scripts/install/install_cockpit.sh"
    ;;
  default)
    echo "No additional role-specific setup defined for default."
    ;;
  auto)
    echo "No additional role-specific setup defined for auto; using default flow."
    ;;
esac

echo "Rebuild flow complete for role: ${ROLE}"
