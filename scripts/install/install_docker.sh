#!/usr/bin/env bash

##############################################################################
#
# Home Lab Setup — Install Docker Natively on the Host
#
##############################################################################

set -e

sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

deb_arch=$(dpkg --print-architecture)
deb_codename=$(. /etc/os-release && echo $VERSION_CODENAME)

echo "deb [arch=${deb_arch} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${deb_codename} stable" |
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

sudo usermod -aG docker $USER

sudo systemctl enable docker
sudo systemctl start docker

echo "Docker installation is complete. Log out and log back in to use Docker without sudo."
