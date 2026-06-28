#!/usr/bin/env bash

##############################################################################
#
# Home Lab Setup — Install Cockpit (Ubuntu 24.04 Clean Version)
#
##############################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing Cockpit (Ubuntu 24.04 optimized)..."

##############################################################################
# Update system
##############################################################################

sudo apt update

##############################################################################
# Samba check
##############################################################################

if ! dpkg -s samba >/dev/null 2>&1; then
    echo "Samba not installed."
    bash "${SCRIPT_DIR}/install_samba.sh"
fi

##############################################################################
# Samba shares
##############################################################################

if [ ! -d "/srv/shares/public" ] || [ ! -d "/srv/shares/private" ]; then
    echo "Samba share directories missing."
    bash "${SCRIPT_DIR}/configure_samba_shares.sh"
fi

##############################################################################
# Install Cockpit (standard Ubuntu repo)
##############################################################################

echo "Installing Cockpit..."

sudo apt install -y \
    cockpit \
    cockpit-podman \
    cockpit-storaged \
    cockpit-pcp

##############################################################################
# Enable Cockpit
##############################################################################

sudo systemctl enable --now cockpit.socket

##############################################################################
# Firewall
##############################################################################

sudo ufw allow 9090/tcp || true

##############################################################################
# Done
##############################################################################

echo ""
echo "Cockpit installed successfully."
echo "Access: https://SERVER-IP:9090"