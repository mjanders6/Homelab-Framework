# Bootserver Installation Guide

This document describes how to install and configure the hybrid Raspberry Pi bootserver module in the Homelab Framework.

## Overview

The `bootserver` module deploys a minimal boot environment on the desktop infrastructure server for Raspberry Pi devices.

It provides:

- A Docker Compose stack with TFTP and nginx
- Per-node boot directories under `/srv/tftp/boot/<node>`
- Cloud-init metadata and user-data for first-boot automation
- Support for Raspberry Pi 4 and Raspberry Pi 5

## Prerequisites

- Ubuntu Server host for the desktop infrastructure server
- `make` and `bash` available
- Docker installed and running on the host
- Network connectivity for Raspberry Pi PXE boot

## Installation

1. Bootstrap the host if needed:

```bash
sudo bash scripts/bootstrap/bootstrap.sh
```

2. Install the bootserver module:

```bash
make install-bootserver
```
### Customizing Raspberry Pi node names

Prior to installation, set `BOOTSERVER_NODE_NAMES` to the node names you want to provision. This creates an independent boot directory for each node.

```bash
export BOOTSERVER_NODE_NAMES="pi5 pi4_network pi4_monitor pi4_backup"
make install-bootserver
```

Comma-separated values are also supported:

```bash
export BOOTSERVER_NODE_NAMES="pi5,pi4_network,pi4_monitor,pi4_backup"
make install-bootserver
```
3. Configure and start the bootserver:

```bash
make configure-bootserver
```

4. Verify the bootserver:

```bash
make verify-bootserver
```

## Boot directories

The module creates per-node, independent directories for each Raspberry Pi node under `/srv/tftp/boot/`.

By default, the install script creates separate directories for:

- `/srv/tftp/boot/pi5`
- `/srv/tftp/boot/pi4_network`
- `/srv/tftp/boot/pi4_monitor`
- `/srv/tftp/boot/pi4_backup`

Each Raspberry Pi 4 node uses its own independent boot directory and does not share boot assets with the other Pi4 systems.

Each node directory should include:

- `meta-data`
- `user-data`
- kernel and initramfs assets as needed

## Example node config

Create `/srv/tftp/boot/<node>/meta-data`:

```yaml
local-hostname: <node-name>
instance-id: <node-name>
```

Create `/srv/tftp/boot/<node>/user-data`:

```yaml
#cloud-config
users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys: []

runcmd:
  - [ sh, -c, 'echo "cloud-init completed on $(hostname)" > /var/log/cloud-init-complete.log' ]
```

## Troubleshooting

- Ensure Docker is running before configuring the bootserver
- Check container status with `make status-bootserver`
- Confirm `/srv/tftp` is populated and the boot files are readable by the containers
