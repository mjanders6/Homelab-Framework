#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Ensure the framework can run from anywhere
cd "${ROOT_DIR}"

# Install prerequisites for a new Homelab host.
# This script is intentionally minimal and idempotent.

if [[ $(id -u) -ne 0 ]]; then
  echo "[ERROR] bootstrap.sh must be run as root or with sudo"
  exit 1
fi

set -x

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

# Install common tools
bash "${ROOT_DIR}/scripts/install/install_git.sh"
bash "${ROOT_DIR}/scripts/install/install_ansible.sh"

# If Webmin is desired, install it optionally
if [[ ${INSTALL_WEBMIN:-false} =~ ^(yes|true|1)$ ]]; then
  bash "${ROOT_DIR}/scripts/install/install_webmin.sh"
fi

# Run verify suite
bash "${ROOT_DIR}/scripts/verify/verify_tools.sh"

cat <<'EOF'
Bootstrap complete.
To continue, run the Homelab playbooks under ansible/playbooks.
Example: ansible-playbook -i localhost, ansible/playbooks/bootstrap.yml
EOF
