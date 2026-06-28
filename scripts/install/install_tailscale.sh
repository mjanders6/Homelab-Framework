#!/usr/bin/env bash

##############################################################################
#
# Home Lab Setup — Install Tailscale for Secure Networking and remote access to your home lab environment. 
# Tailscale creates a secure mesh VPN, allowing you to connect to your devices from anywhere with ease.
#
##############################################################################

set -e

curl -fsSL https://tailscale.com/install.sh | sh

sudo systemctl enable tailscaled
sudo systemctl start tailscaled

echo "Run sudo tailscale up"
