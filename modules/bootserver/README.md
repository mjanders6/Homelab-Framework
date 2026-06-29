# Bootserver Module

The `bootserver` module installs and configures the hybrid Raspberry Pi bootserver for the Homelab Framework.

This module provides a small self-hosted PXE/cloud-init boot environment using Docker Compose.

## What it does

- Creates bootserver directories under `/opt/services/bootserver`
- Creates TFTP and nginx boot assets under `/srv/tftp`
- Deploys a Docker Compose stack for TFTP and HTTP delivery
- Creates independent directories for each Raspberry Pi node by default:
  - `/srv/tftp/boot/pi5`
  - `/srv/tftp/boot/pi4_network`
  - `/srv/tftp/boot/pi4_monitor`
  - `/srv/tftp/boot/pi4_backup`
- Ensures Raspberry Pi 4 nodes do not share a single boot area; each node is independent.
- Uses `cloud-init` metadata and user-data to automate first-boot configuration

## Capabilities

- `install`
- `configure`
- `verify`
- `status`
- `remove`

## Usage

Install the module and its dependencies:

```bash
make install-bootserver
```

Configure and start the bootserver:

```bash
make configure-bootserver
```

Verify the bootserver status:

```bash
make verify-bootserver
make status-bootserver
```

## Notes

Each Raspberry Pi should use PXE to fetch kernel and initramfs assets from the desktop bootserver, then use its local SSD for the root filesystem.

Per-node configuration files live under `/srv/tftp/boot/<node>/`.
