#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DRY_RUN="${DRY_RUN:-false}"

# Ensure the framework can run from anywhere
cd "${ROOT_DIR}"

# Install prerequisites for a new Homelab host.
# This script is intentionally minimal and idempotent.

run_script() {
  local script_path="$1"
  if [[ "${DRY_RUN}" =~ ^(yes|true|1)$ ]]; then
    echo "[DRY-RUN] bash ${script_path}"
  else
    bash "${script_path}"
  fi
}

if [[ $(id -u) -ne 0 ]]; then
  if [[ "${DRY_RUN}" =~ ^(yes|true|1)$ ]]; then
    echo "[DRY-RUN] Running as non-root; skipping privileged package installation."
  else
    echo "[ERROR] bootstrap.sh must be run as root or with sudo"
    exit 1
  fi
fi

set -x

if [[ "${DRY_RUN}" =~ ^(yes|true|1)$ ]]; then
  echo "[DRY-RUN] apt-get update -y"
  echo "[DRY-RUN] apt-get upgrade -y"
  echo "[DRY-RUN] apt-get install -y curl wget git make python3 python3-pip ansible"
else
  apt-get update -y
  apt-get upgrade -y
  apt-get install -y \
      curl \
      wget \
      git \
      make \
      python3 \
      python3-pip \
      ansible
fi

# Install common tools
run_script "${ROOT_DIR}/scripts/install/install_git.sh"
run_script "${ROOT_DIR}/scripts/install/install_ansible.sh"

# If Webmin is desired, install it optionally
if [[ ${INSTALL_WEBMIN:-false} =~ ^(yes|true|1)$ ]]; then
  run_script "${ROOT_DIR}/scripts/install/install_webmin.sh"
fi

# Run verify suite
run_script "${ROOT_DIR}/scripts/verify/verify_tools.sh"

cat <<'EOF'
Bootstrap complete.
To continue, run the Homelab playbooks under ansible/playbooks.
Example: ansible-playbook -i localhost, ansible/playbooks/bootstrap.yml
EOF
