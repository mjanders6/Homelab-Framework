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
- `RPI3_SERVER_ROLE` — role assigned to the command-node host; defaults to `pi5`.
- `RPI2_SERVER_IP` and `RPI2_SERVER_MAC` — networking node.
- `RPI2_SERVER_ROLE` — role assigned to that host; defaults to `pi4_network`.
- `RPI1_SERVER_IP` and `RPI1_SERVER_MAC` — monitoring node.
- `RPI1_SERVER_ROLE` — role assigned to that host; defaults to `pi4_monitor`.
- `RPI0_SERVER_IP` and `RPI0_SERVER_MAC` — backup node.
- `RPI0_SERVER_ROLE` — role assigned to that host; defaults to `pi4_backup`.
- `TOWER_SERVER_IP` and `TOWER_SERVER_ROLE` — address and role for the desktop/infrastructure host; the role defaults to `desktop`.

Notes:

- If required variables are missing when the scripts run, a validation error will be printed and execution will stop. To bypass validation (not recommended), set `SKIP_ENV_VALIDATION=1` in the environment.


## One-command install

After cloning the repository on the fresh host, run the role-specific install target. It runs bootstrap, common setup, and role-specific setup in one idempotent flow:

```bash
sudo make install ROLE=pi5
```

Use `desktop`, `pi4_network`, `pi4_monitor`, or `pi4_backup` for the other supported roles. To inspect the selected role without changing the host, use:

```bash
DRY_RUN=true sudo -E make install ROLE=pi5
```

The older `make rebuild-<role>` targets remain available as explicit aliases for recovery and backwards compatibility.

The software assigned to each role is documented in the [architecture role profiles](../../ARCHITECTURE.md#26-role-profiles-and-software-ownership). The install command applies the shared foundation first, then the software for the selected role.

## Reassigning a host role

Host addresses and roles are separate. To move a function to another host, edit the `*_SERVER_ROLE` values in `.env`, then run the install command using the role assigned to that host. For example, to make `rpi2-server` the monitoring host and `rpi1-server` the networking host:

```env
RPI2_SERVER_ROLE=pi4_monitor
RPI1_SERVER_ROLE=pi4_network
```

Then install each host with its new role:

```bash
# Run on rpi2-server
sudo make install ROLE=pi4_monitor

# Run on rpi1-server
sudo make install ROLE=pi4_network
```

The CLI reads these assignments when selecting a host. Keep each role assigned to only one host to avoid ambiguous role-to-host lookups.

## Bootstrap

The install target calls the bootstrap script automatically. Run it directly only when preparing a command node or repairing prerequisites:

```bash
sudo bash scripts/bootstrap/bootstrap.sh
```

If you prefer to use the module framework directly, install the core module dependencies first:

```bash
sudo bash scripts/lib/modules.sh run install filesystem
sudo bash scripts/lib/modules.sh run install logging
sudo bash scripts/lib/modules.sh run install network
```

For a normal fresh install, do not run bootstrap and the role target separately; use the one-command install flow above. This replaces the older bootserver-based and K3s-first provisioning flow.

## Recovery after reinstall

To return a node to service after reinstalling it from an approved local image:

1. Confirm network access and SSH connectivity from the command node.
2. Run `sudo make install ROLE=pi5` or the matching role target.
3. Check `make module-status` and run the relevant `make verify-<module>` targets.
4. Re-run the role target after an interrupted step; the bootstrap and module lifecycle scripts are intended to be idempotent.

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
