#!/usr/bin/env bash

##############################################################################
#
# Home Lab Setup — Install Common Packages for the Infrastructure Server
#
##############################################################################

set -e

sudo apt update
sudo apt upgrade -y

sudo apt install -y \
    curl \
    wget \
    git \
    vim \
    htop \
    unzip \
    net-tools \
    ca-certificates \
    gnupg \
    lsb-release
