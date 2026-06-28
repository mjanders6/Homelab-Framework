#!/usr/bin/env bash

##############################################################################
#
# Home Lab Setup — Install Jellyfin Media Server
#
##############################################################################

set -e

curl -fsSL https://repo.jellyfin.org/install-debuntu.sh | sudo bash

sudo apt install -y jellyfin

sudo systemctl enable jellyfin
sudo systemctl start jellyfin
