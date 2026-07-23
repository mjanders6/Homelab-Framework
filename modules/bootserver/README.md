# Bootserver Module

The `bootserver` module is being phased out as the framework shifts to a rebuild-first workflow.

This module previously provided a self-hosted PXE/cloud-init boot environment using Docker Compose, but the supported path is now to reinstall the OS and then run the framework rebuild flow.

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
- Used to be responsible for cloud-init-driven first-boot provisioning

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

The old workflow relied on a bootserver and PXE path, but the supported direction is now a fresh OS install followed by the framework rebuild flow.
