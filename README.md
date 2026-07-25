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

- `make rebuild-default` — Start the rebuild flow for a fresh node install.
- `make rebuild-pi5` — Rebuild a Pi 5 node using the bootstrap and role-specific setup flow.
- `make rebuild-desktop` — Rebuild the desktop/infrastructure host using the same path.

The supported rebuild workflow now starts from a fresh OS install and uses the framework bootstrap plus role-specific automation instead of a network boot environment.

The repository is also moving away from the legacy bootserver and K3s-centric approach, with the rebuild-first path becoming the primary supported model.

Current milestone: Sprint 1 is complete. The repository now includes a versioned role-image workflow, validation guidance, smoke tests, and CI coverage for the image build path.

## Rebuild workflow

A first rebuild entrypoint is now available for fresh OS installs:

```bash
make rebuild-default
# or
make rebuild-pi5
make rebuild-desktop
```

This starts the bootstrap flow for a newly installed node and is intended as the first step toward a network-boot-free rebuild experience.

For full architecture and project standards, see [ARCHITECTURE.md](ARCHITECTURE.md).
