#!/usr/bin/env bash

##############################################################################
#
# Home Lab Setup — Install Webmin (Ubuntu 24.04 Compatible)
#
##############################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

WEBMIN_SH="webmin-setup-repo.sh"

echo "Installing Webmin..."

##############################################################################
# Update Packages
##############################################################################

sudo apt update

##############################################################################
# Ensure Samba Installed
##############################################################################

if ! dpkg -s samba >/dev/null 2>&1; then
    echo "Samba not installed."
    bash "${SCRIPT_DIR}/install_samba.sh"
fi

##############################################################################
# Ensure Samba Shares Configured
##############################################################################

if [ ! -d "/srv/shares/public" ] || \
   [ ! -d "/srv/shares/private" ]; then

    echo "Samba share directories missing."
    bash "${SCRIPT_DIR}/configure_samba_shares.sh"
fi

##############################################################################
# Install Dependencies
##############################################################################

sudo apt install -y \
    wget \
    curl \
    perl \
    libnet-ssleay-perl \
    openssl \
    libauthen-pam-perl \
    libpam-runtime \
    libio-pty-perl \
    apt-show-versions \
    python3

##############################################################################
# Download Webmin Package
##############################################################################

cd /tmp

curl -o ${WEBMIN_SH} https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repo.sh


##############################################################################
# Install Webmin with Script
##############################################################################

sudo sh ${WEBMIN_SH}
sudo apt-get install -y \
    --install-recommends \
    webmin \
    usermin

##############################################################################
# Firewall Rules
##############################################################################

sudo ufw allow 10000/tcp || true

##############################################################################
# Cleanup
##############################################################################

rm -f /tmp/${WEBMIN_SH}

##############################################################################
# Status
##############################################################################

echo ""
echo "Webmin installed successfully."
echo ""
echo "Access:"
echo "  https://SERVER-IP:10000"
echo ""
echo "Samba management:"
echo "  Servers -> Samba Windows File Sharing"