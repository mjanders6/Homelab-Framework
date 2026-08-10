# Development Guide

This document helps developers extend Homelab Framework, add modules, and maintain the core automation platform.

## Repository Layout

- `modules/` — Framework plugins. Each module has a manifest and lifecycle scripts.
- `scripts/lib/` — Shared Bash libraries for logging, error handling, filesystem operations, networking, module discovery, and framework utilities.
- `scripts/` — Procedural scripts for bootstrapping, installation, configuration, verification, backup, restore, cleanup, and utilities.
- `ansible/` — Infrastructure as code components for provisioning the homelab network and cluster.
- `tests/` — Unit, integration, and smoke test scaffolding.
- `docs/` — Documentation for architecture, installation, development, releases, roadmap, and troubleshooting.

## Module Development

### Module contract

Every module must provide:

- `module.yml` — module manifest
- `install.sh` — install lifecycle
- `configure.sh` — configure lifecycle
- `verify.sh` — verification lifecycle
- `status.sh` — health/status output
- `remove.sh` — uninstall lifecycle
- `report.sh` — optional summary report

Supported actions:

- `install`
- `configure`
- `verify`
- `status`
- `remove`
- `backup` (optional)
- `restore` (optional)
- `update` (optional)
- `upgrade` (optional)
- `report` (optional)

### Creating a new module

1. Add `modules/<module>/module.yml`.
2. Add lifecycle scripts in `modules/<module>/`.
3. Source shared helpers from `scripts/lib/`.
4. Add `modules/<module>/README.md` for documentation.
5. Test with `make install-<module>` and `make verify-<module>`.

### Dependency resolution

The loader resolves dependencies automatically for `install`, `configure`, and `verify`.

```bash
make install-<module>
```

This installs dependencies first before the target module.

## Framework extension

### Shared helper libraries

- `scripts/lib/logging.sh`
- `scripts/lib/error.sh`
- `scripts/lib/filesystem.sh`
- `scripts/lib/network.sh`
- `scripts/lib/packages.sh`
- `scripts/lib/modules.sh`
- `scripts/lib/framework.sh`

### Adding new helpers

1. Create a new helper file in `scripts/lib/`.
2. Keep utilities reusable and idempotent.
3. Use `abort`, `log_info`, `log_warn`, and `log_error` for consistent output.

## Testing

- Write unit tests for Bash helper functions.
- Add integration tests for module dependency and lifecycle behavior.
- Use smoke tests for end-to-end workflows.

## Development workflow

1. Branch from `main`.
2. Add or update module manifests/scripts.
3. Add documentation and tests.
4. Run `make help`, `make modules`, and module-specific lifecycle commands.
5. Commit with a clear message.
6. Open a pull request with testing notes.
