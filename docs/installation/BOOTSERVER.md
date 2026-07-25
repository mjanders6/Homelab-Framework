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

## User Guide

### 1. Prepare the static node inventory

Set MAC and IP addresses in [`.env`](../../.env.example) (copy from `.env.example`):

```bash
PI5_MAC=dc:a6:32:aa:bb:cc
PI5_IP=192.168.1.51
NETWORK_GATEWAY=192.168.1.1
NETWORK_NAMESERVER=192.168.1.1
```

Package lists and post-boot commands stay in [ansible/group_vars/bootserver_mac_ip_map.yml](../../ansible/group_vars/bootserver_mac_ip_map.yml). Shared gateway/DNS defaults are in [ansible/group_vars/network.yml](../../ansible/group_vars/network.yml). Env vars override the YAML map at render time.

### 2. Generate the boot assets for each Raspberry Pi

Use the following workflow to generate the per-node directories and cloud-init configuration payloads:

```bash
make install-bootserver
make build-golden-image
make bootserver-k3s
make configure-bootserver
```

The `make build-golden-image` target renders the following files for every node listed in `BOOTSERVER_NODE_NAMES`:

- `/srv/tftp/boot/<node>/meta-data`
- `/srv/tftp/boot/<node>/user-data`
- `/srv/tftp/boot/<node>/network-config`
- `/srv/tftp/boot/<node>/vendor-data`

### 3. Customize a node profile

If a node needs additional software, update its entry in [ansible/group_vars/bootserver_mac_ip_map.yml](../../ansible/group_vars/bootserver_mac_ip_map.yml) and rerun:

```bash
make build-golden-image
```

This regenerates the node-specific cloud-init files so the next PXE boot uses the updated profile.

### 4. Boot a Raspberry Pi from the network

1. Configure the Raspberry Pi to use PXE/network boot in the firmware.
2. Ensure the Pi is on the same subnet as the bootserver.
3. Power on the device.
4. Let the Pi retrieve the kernel/initramfs assets from the TFTP server and apply the cloud-init configuration from `/srv/tftp/boot/<node>/`.
5. After first boot, confirm the static IP assignment, installed packages, and K3s join behavior are correct.

### 5. Verify the bootserver state

```bash
make verify-bootserver
```

You can also inspect the generated boot assets directly under `/srv/tftp/boot/`.

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
