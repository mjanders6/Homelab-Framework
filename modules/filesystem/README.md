# filesystem module

The `filesystem` module provides shared filesystem utilities and foundational checks used by Homelab Framework modules.

## Capabilities

- install
- configure
- verify
- status
- remove
- report

## Files

- `module.yml` — module manifest
- `install.sh` — module install lifecycle
- `configure.sh` — module configure lifecycle
- `verify.sh` — module verify lifecycle
- `status.sh` — module health status
- `remove.sh` — remove lifecycle
- `report.sh` — module summary report

## Usage

Run the module lifecycle actions directly:

```bash
make install-filesystem
make verify-filesystem
make status-filesystem
```
