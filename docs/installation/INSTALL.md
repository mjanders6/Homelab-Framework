# Installation

This document explains how to bootstrap and install Homelab Framework on a fresh Ubuntu host.

## Prerequisites

- Ubuntu Server 20.04 or later
- `sudo` access
- Network connectivity to required package repositories

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

## Module installation

The framework exposes `make` targets for modules and module helpers.

List available modules:

```bash
make modules
```

Install a module and its declared dependencies:

```bash
make install-k3s
```

Install only module dependencies for `k3s`:

```bash
make install-dependencies-k3s
```

Verify a module:

```bash
make verify-k3s
```

Get module status:

```bash
make module-status
```
