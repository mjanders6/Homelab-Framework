#!/usr/bin/env bash

##############################################################################
#
# Home Lab Setup — Set Up Directory Structure for Services
#
##############################################################################

set -e

sudo mkdir -p /opt/services
sudo mkdir -p /srv/media
sudo mkdir -p /srv/backups
sudo mkdir -p /srv/docker
sudo mkdir -p /srv/shares

sudo chown -R $USER:$USER /opt/services
