# Homelab Framework

Homelab Framework is a reproducible, modular Infrastructure-as-Code platform for building and managing a homelab environment from a fresh Ubuntu Server installation.

This repository provides:

- Automated bootstrap and installation workflows
- Modular Bash scripts and Ansible components
- A stable framework contract for install/configure/verify/remove lifecycle operations
- A shared logging and error-handling model
- A consistent directory layout for scripts, playbooks, configs, and tests

Designed for:

- Automation-first deployments
- Idempotent and repeatable infrastructure provisioning
- Modular service composition
- Infrastructure verification and documentation

Key directories:

- `ansible/` — Inventories, playbooks, roles, templates, and collection metadata
- `docs/` — Architecture, installation, development, release, and troubleshooting documentation
- `scripts/` — Bootstrap, install, configure, verify, backup, restore, cleanup, utilities, and shared libraries
- `tests/` — Unit, integration, and smoke test scaffolding
- `configs/` — User-editable configuration templates

Bootserver module:

- `make install-bootserver` — Install the hybrid Raspberry Pi bootserver module on the desktop infrastructure server.
- `make build-golden-image` — Generate per-node cloud-init boot assets for Raspberry Pi 4/5 network booting.
- `make bootserver-k3s` — Install K3s on the bootserver so it can manage the Pi worker nodes.
- `make configure-bootserver` — Start the Docker Compose-managed TFTP and nginx bootserver stack.

The bootserver installs per-node directories under `/srv/tftp/boot/` for each Pi node, and uses cloud-init for first-boot configuration so the OS is never manually configured on the Pi.

Customize the supported Pi nodes before installation by setting `BOOTSERVER_NODE_NAMES`:

```bash
export BOOTSERVER_NODE_NAMES="pi5 pi4_network pi4_monitor pi4_backup"
make install-bootserver
```

You can also use comma-separated node names:

```bash
export BOOTSERVER_NODE_NAMES="pi5,pi4_network,pi4_monitor,pi4_backup"
make install-bootserver
```

Each Raspberry Pi is expected to boot via PXE to receive kernel and initramfs files, then continue booting from the local SSD root filesystem using cloud-init for first-boot configuration.

The bootserver workflow is driven by the static node map in [ansible/group_vars/bootserver_mac_ip_map.yml](ansible/group_vars/bootserver_mac_ip_map.yml), which defines the per-node MAC address, static IP, and cloud-init packages/bootstrap commands used during provisioning.

For full architecture and project standards, see [ARCHITECTURE.md](ARCHITECTURE.md).
