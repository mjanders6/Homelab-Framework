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

CLI workflow (v3.0.0):

- `make cli` - Launch the interactive command-node CLI.
- `make run PLAYBOOK=bootstrap HOST=rpi1 [CHECK=1]` - Run a playbook on a host; also `make hosts` and `make playbooks`.
- `scripts/cli/homelab-cli.sh run <playbook> --host <host>` - Run an Ansible playbook against any host. No host is tied to a role.

See [docs/cli/README.md](docs/cli/README.md). The legacy role-based rebuild scripts remain in `scripts/rebuild` but are no longer part of the supported CLI.

For full architecture and project standards, see [ARCHITECTURE.md](ARCHITECTURE.md).

## Recovery after reinstall

1. Confirm SSH access from the command node.
2. Run `scripts/cli/homelab-cli.sh run bootstrap --host <host>`
3. Run any further playbooks for that host.


