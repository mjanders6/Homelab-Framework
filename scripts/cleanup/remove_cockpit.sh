#!/usr/bin/env bash
set -e

sudo systemctl stop cockpit.socket || true

sudo apt purge -y   cockpit   cockpit-podman   cockpit-storaged   cockpit-pcp

sudo apt autoremove -y

echo "Cockpit removed."
