# Module Troubleshooting

This page helps developers debug module dependency resolution and lifecycle execution in Homelab Framework.

## Common symptoms

- `make install-k3s` fails before reaching the `k3s` module
- a dependency module is skipped or run in the wrong order
- `verify` reports missing binaries or inactive services
- module lifecycle scripts exit unexpectedly

## Check module manifests

Each module must declare dependencies in `modules/<module>/module.yml`.

Example:

```yaml
name: k3s
description: Lightweight Kubernetes cluster deployment.
version: 1.0.0
category: cluster
capabilities:
  - install
  - configure
  - verify
  - status
  - remove
dependencies:
  - docker
  - network
```

If a dependency is missing or misspelled, the framework cannot resolve the graph correctly.

## Verify module scripts

Ensure each module has the required lifecycle scripts for the actions you intend to run.

Required files:

- `modules/<module>/install.sh`
- `modules/<module>/configure.sh`
- `modules/<module>/verify.sh`
- `modules/<module>/status.sh`
- `modules/<module>/remove.sh`

Optional files:

- `modules/<module>/backup.sh`
- `modules/<module>/restore.sh`
- `modules/<module>/update.sh`
- `modules/<module>/upgrade.sh`
- `modules/<module>/report.sh`

If a module is expected to support `install`, `configure`, or `verify`, those scripts must exist and be executable.

## Check script permissions

Make sure all module scripts are executable:

```bash
find modules -type f -name '*.sh' | xargs chmod +x
```

The module loader also attempts to set execute permissions automatically, but explicit permissions prevent failures.

## Validate dependency resolution

The module helper resolves dependencies before executing `install`, `configure`, or `verify`.

To inspect the resolved order manually, use:

```bash
bash scripts/lib/modules.sh run install k3s
```

If there is a dependency cycle, the loader will report:

```text
Dependency cycle detected: <module>
```

### Debugging dependency cycles

- Check each manifest's `dependencies:` section.
- Confirm the graph does not form a loop.
- Use a text search for the module names involved.

## Debugging module action execution

If a module action fails, inspect the script and use logging helpers.

- Ensure the script starts with:
  - `#!/usr/bin/env bash`
  - `set -euo pipefail`
- Use shared logging functions in `scripts/lib/logging.sh`:
  - `log_info`, `log_debug`, `log_warn`, `log_error`
- Use `abort` from `scripts/lib/error.sh` for fatal failures.

Example:

```bash
log_info "Starting module action"
if ! command -v docker >/dev/null 2>&1; then
  abort "Docker not installed"
fi
```

## Use the module loader directly

The loader supports the following commands:

```bash
bash scripts/lib/modules.sh list_modules
bash scripts/lib/modules.sh run install <module>
bash scripts/lib/modules.sh run verify <module>
bash scripts/lib/modules.sh deps <module>
bash scripts/lib/modules.sh diagnose <module>
```

This is useful when `make` masking hides the underlying failure.

### Helpful Make aliases

The Makefile exposes convenience targets for common module diagnostics:

```bash
make deps-k3s
make diagnose-k3s
```

`make deps-k3s` prints the resolved dependency execution order.

`make diagnose-k3s` prints the module manifest, dependency order, and lifecycle script status.

## Typical resolution steps

1. Confirm the manifest is valid YAML and dependency names are correct.
2. Confirm required lifecycle scripts exist and are executable.
3. Run the failing module action directly with `bash scripts/lib/modules.sh run <action> <module>`.
4. Review script output for missing tools, permission errors, or failed commands.
5. Add `log_debug` checkpoints in the failing script if necessary.
6. If dependency resolution is wrong, verify `dependencies:` lists the complete chain.

## Example: fix a failing `install-k3s`

1. Confirm `modules/k3s/module.yml` includes `docker` and `network`.
2. Confirm `modules/docker/install.sh` and `modules/network/install.sh` exist.
3. Run:

```bash
bash scripts/lib/modules.sh run install k3s
```

4. If a dependency action fails, fix that module first.

## Additional notes

- The framework currently resolves dependencies only for `install`, `configure`, and `verify`.
- Non-dependent actions such as `status`, `remove`, `backup`, and `restore` do not automatically traverse dependencies.
- Keep module manifests and scripts aligned to prevent graph issues.
