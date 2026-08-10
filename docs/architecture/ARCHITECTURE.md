# Architecture Overview

Homelab Framework is a modular Bash-based automation platform for building reproducible homelab infrastructure.

## Core Principles

- **Infrastructure as Code**: All configuration and deployment logic is source-controlled.
- **Modularity**: Each feature is expressed as a reusable module with lifecycle actions.
- **Idempotency**: Repeated execution should produce the same result.
- **Extensibility**: New modules should be addable without changing framework core logic.
- **Observability**: Help, dependency metadata, status, and verification are generated from module metadata.

## Module Contract

Each module must include a `module.yml` manifest describing:

- `name`
- `description`
- `version`
- `category`
- `capabilities`
- `dependencies`

Module lifecycle scripts are stored in the module directory and executed via the framework module loader.

## Directory Structure

- `modules/<module>/module.yml`
- `modules/<module>/install.sh`
- `modules/<module>/configure.sh`
- `modules/<module>/verify.sh`
- `modules/<module>/status.sh`
- `modules/<module>/remove.sh`
- `modules/<module>/report.sh`

## Dependency Resolution

The framework resolves module dependencies automatically for the following actions:

- `install`
- `configure`
- `verify`

Dependencies are declared in `module.yml`. Example:

```yaml
dependencies:
  - docker
  - network
```

This allows an install target such as `make install-<module>` to install its declared dependencies first.
