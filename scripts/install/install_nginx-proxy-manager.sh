#!/usr/bin/env bash

##############################################################################
#
# Home Lab Setup — Install Nginx Proxy Manager 
#
##############################################################################

set -e

sudo mkdir -p /opt/services/npm
cd /opt/services/npm

cat <<EOF | sudo tee -a /opt/services/npm/docker-compose.yml

services:
  nginx-proxy-manager:
    image: 'jc21/nginx-proxy-manager:latest'
    container_name: nginx-proxy-manager

    restart: unless-stopped

    ports:
      - "80:80"
      - "81:81"
      - "443:443"

    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
EOF