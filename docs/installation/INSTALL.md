# Installation

This document explains how to bootstrap and install Homelab Framework on a fresh Ubuntu host.

The supported path is now a rebuild-first workflow that avoids the legacy bootserver and K3s-centric approach. New deployments should start from a fresh OS installation and proceed through the framework bootstrap and role automation flow.

## Prerequisites

- Ubuntu Server 20.04 or later
- `sudo` access
- Network connectivity to required package repositories

## Create the `.env` file

The framework reads settings from a `.env` file in the repository root. Copy the example and edit the values for your network and node addresses:

```bash
cp .env.example .env
# then edit .env with your editor
```

Recommended variables (minimum set required):

- `NETWORK_GATEWAY` — your LAN gateway address (e.g. `192.168.1.1`).
- `NETWORK_NAMESERVER` — DNS nameserver for the network.
- `NETWORK_PROBE_IP` — optional probe IP used for network checks.
- `RPI3_SERVER_IP` and `RPI3_SERVER_MAC` — command-node / management host.
- `RPI2_SERVER_IP` and `RPI2_SERVER_MAC` — networking node.
- `RPI1_SERVER_IP` and `RPI1_SERVER_MAC` — monitoring node.
- `RPI0_SERVER_IP` and `RPI0_SERVER_MAC` — backup node.

Notes:

- If required variables are missing when the scripts run, a validation error will be printed and execution will stop. To bypass validation (not recommended), set `SKIP_ENV_VALIDATION=1` in the environment.


## Bootstrap

Use the bootstrap script in `scripts/bootstrap/bootstrap.sh` to install prerequisites and verify the host.

```bash
sudo bash scripts/bootstrap/bootstrap.sh
```

If you prefer to use the module framework directly, install the core module dependencies first:

```bash
sudo bash scripts/lib/modules.sh run install filesystem
sudo bash scripts/lib/modules.sh run install logging
sudo bash scripts/lib/modules.sh run install network
```

For rebuild-based setup, start with the bootstrap flow and then run a rebuild target such as `make rebuild-pi5` or `make rebuild-desktop`. This is the recommended path for new installs and replaces the older bootserver-based and K3s-first provisioning flow.

## Module installation

The framework exposes `make` targets for modules and module helpers.

List available modules:

```bash
make modules
```

Install a module and its declared dependencies:

```bash
make install-<module>
```

Verify a module:

```bash
make verify-<module>
```

Get module status:

```bash
make module-status
```

Interactive CLI for the command node:

```bash
make cli
```

The CLI now supports:

- Hostname-based rebuild selection for remote servers such as `rpi3-server`, `rpi2-server`, `rpi1-server`, `rpi0-server`, and `tower-server`.
- Installing standalone framework modules on remote nodes by hostname.
