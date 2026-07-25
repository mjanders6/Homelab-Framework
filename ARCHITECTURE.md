# ARCHITECTURE.md

# Homelab Framework

**Architecture Specification**

Version: **2.0.0**

Codename: **Sprint 2**

Status: Draft

```
                     Internet
                        │
                    Router/Switch
                        │
            ┌─────────────────────────┐
            │ Desktop:                |
            |   Infrastructure Server │
            ├─────────────────────────┤
            │ DHCP                    │
            │ DNS                     │
            │ NFS                     │
            │ Samba                   │
            │ Git                     │
            │ Docker Registry         │
            │ Prometheus              │
            │ Grafana                 │
            │ Ansible                 │
            │ Longhorn Backup Storage │
            │ Rebuild Automation      │
            └─────────────────────────┘
                        │
            Fresh OS + bootstrap + role automation
                        │
        ┌──────────┬──────────┬──────────┐
        │          │          │          │
        Pi 5      Pi 4       Pi 4       Pi 4
```

---

# 1. Purpose

This document defines the architectural principles, conventions, and development standards for the Homelab Framework.

The objective of the framework is to provide a fully automated, reproducible Infrastructure-as-Code (IaC) platform capable of rebuilding an entire homelab environment from a fresh Ubuntu Server installation using a single source-controlled repository.

The framework is intentionally moving away from the legacy bootserver and K3s-centric deployment model toward a rebuild-first workflow that starts from a fresh OS install and uses the shared bootstrap and role automation path.

The framework emphasizes:

* Automation
* Repeatability
* Modularity
* Testability
* Documentation
* Idempotency
* Extensibility

This document serves as the governing specification for all project development, including the migration away from network-boot, bootserver-based provisioning, and older K3s-specific assumptions.

---

# 2. Architectural Principles

The framework shall adhere to the following principles.

## 2.1 Infrastructure as Code

Every infrastructure component must be defined in source control.

No permanent configuration changes shall be made manually.

Manual changes must be incorporated into automation before they become part of the supported configuration.

---

## 2.2 Idempotency

Running any installation or configuration task multiple times shall produce the same result.

Repeated execution must not:

* duplicate configuration
* corrupt configuration
* reinstall unnecessarily
* generate inconsistent system state

---

## 2.3 Modularity

Every feature is an independent module.

Modules shall contain four operations:

* Install
* Configure
* Verify
* Remove

Modules must not depend on unrelated modules.

---

## 2.4 Layered Architecture

Each layer depends only on lower layers.

```
Ubuntu Server

↓

Bootstrap

↓

Framework Core

↓

Infrastructure Services

↓

Storage

↓

Networking

↓

Automation

↓

Cluster

↓

Applications
```

No layer may bypass lower layers.

---

## 2.5 Automation First

Manual procedures are temporary.

If a procedure is repeated more than once, it should become automated.

The preferred automation path is a rebuild-first experience that does not depend on a bootserver or PXE flow, and that does not rely on K3s as the default control-plane assumption for every deployment.

---

# 3. Directory Structure

```
homelab-framework/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   ├── workflows/
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── CODEOWNERS
├── docs/
├── scripts/
├── ansible/
├── tests/
├── configs/
├── templates/
├── releases/
├── Makefile
├── VERSION
├── CHANGELOG.md
├── ARCHITECTURE.md
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
└── README.md
```

---

## ansible/

Contains all Ansible components.

* inventories
* playbooks
* roles
* templates
* collections
* group_vars

---

## configs/

Contains user-editable configuration.

No scripts shall modify configuration templates directly.

---

## docs/

Contains project documentation.

Required documentation:

* Architecture
* Installation
* Development
* Troubleshooting
* Release Notes
* Roadmap

---

## scripts/

Contains framework automation.

Subdirectories:

bootstrap

install

configure

verify

backup

restore

cleanup

utilities

lib

---

## tests/

Contains testing framework.

```
tests/

unit/

integration/

smoke/
```

---

# 4. Coding Standards

## Bash

Requirements:

* Bash 5+
* ShellCheck compliant
* `set -euo pipefail`
* Functions only
* No duplicated logic
* Shared libraries required

Every script begins with:

```bash
#!/usr/bin/env bash

set -euo pipefail
```

Scripts shall source framework libraries.

```
logging.sh

error.sh

filesystem.sh

packages.sh
```

---

## Makefiles

Rules:

* One responsibility per target
* No business logic
* Targets call scripts
* Targets must be idempotent

Example:

```
bootstrap

verify

status

doctor
```

---

## Ansible

Requirements:

* Roles over large playbooks
* No inline shell unless necessary
* Variables stored in group_vars
* Templates use Jinja2

Playbooks orchestrate.

Roles perform work.

---

# 5. Logging Standards

Every framework component shall use the logging library.

Available log levels:

```
DEBUG

INFO

NOTICE

SUCCESS

WARNING

ERROR

FATAL
```

Log format:

```
[2026-06-27 12:30:45]

[INFO]

Installing Docker...
```

Logs stored in

```
logs/YYYY-MM-DD/
```

---

# 6. Error Handling

All scripts shall use centralized error handling.

Functions:

```
check_root()

require_package()

retry()

rollback()

abort()

confirm()
```

No script shall silently ignore errors.

---

# 7. Configuration Management

Configuration precedence:

1. Environment variables
2. .env
3. YAML configuration
4. Module defaults

Runtime values always override defaults.

No hardcoded hostnames, IP addresses, usernames, or paths.

---

# 8. Naming Conventions

## Bash

Functions

```
install_git()

verify_webmin()
```

Variables

```
HOSTNAME

LOG_DIR

INSTALL_PATH
```

Constants

Uppercase only.

---

## Ansible

Roles

```
docker

webmin

common

ssh
```

Playbooks

```
bootstrap.yml

infrastructure.yml

cluster.yml
```

---

## Make Targets

Lowercase

Single responsibility

Examples

```
bootstrap

verify

doctor

status
```

---

# 9. Module Dependencies

Every module shall declare dependencies.

Example

```
docker

depends on

common
```

```
webmin

depends on

common
```

Circular dependencies are prohibited.

---

# 10. Framework Contracts

## 10.1 Purpose

Framework Contracts define the minimum capabilities that every module within the Homelab Framework must implement.

These contracts establish a common interface between the framework, Makefile, Bash libraries, Ansible roles, and future modules.

The goal is to ensure every module behaves consistently, regardless of its purpose.

A module may install Docker, configure Webmin, deploy K3s, or manage backups—the framework interacts with each using the same contract.

---

# 10.2 Required Module Interface

Every module shall implement the following lifecycle operations.

| Operation | Required | Purpose                                    |
| --------- | -------- | ------------------------------------------ |
| install   | Yes      | Install required packages and dependencies |
| configure | Yes      | Apply configuration and templates          |
| verify    | Yes      | Validate successful installation           |
| status    | Yes      | Report current module health               |
| remove    | Yes      | Safely uninstall the module                |
| backup    | Optional | Backup configuration and data              |
| restore   | Optional | Restore from backup                        |
| update    | Optional | Update packages and configuration          |
| upgrade   | Optional | Perform major version upgrades             |
| report    | Optional | Produce a module summary                   |

Modules that do not support backup or restore shall explicitly return **Not Supported** rather than silently failing.

---

# 10.3 Required Directory Structure

Every module shall follow the same directory layout.

```text
scripts/

install/
    install_<module>.sh

configure/
    configure_<module>.sh

verify/
    verify_<module>.sh

cleanup/
    remove_<module>.sh

backup/
    backup_<module>.sh

restore/
    restore_<module>.sh
```

Example:

```text
install_webmin.sh

configure_webmin.sh

verify_webmin.sh

remove_webmin.sh

backup_webmin.sh

restore_webmin.sh
```

---

# 10.4 Required Ansible Components

Every infrastructure module shall provide:

```text
roles/

<module>/

tasks/

handlers/

defaults/

vars/

templates/

files/

README.md
```

Roles shall be self-contained.

Dependencies shall be declared using Ansible metadata.

---

# 10.5 Required Logging

Every module shall use the shared logging library.

Minimum log events:

```text
Module Started

Dependency Check

Installation

Configuration

Verification

Completion

Failure (if applicable)
```

Example:

```text
[INFO]

Installing Docker...

[SUCCESS]

Docker installation completed.
```

No module may write directly to stdout for operational messages except through the logging framework.

---

# 10.6 Exit Codes

All modules shall use standardized exit codes.

| Code | Meaning               |
| ---- | --------------------- |
| 0    | Success               |
| 1    | General Failure       |
| 2    | Missing Dependency    |
| 3    | Invalid Configuration |
| 4    | Verification Failed   |
| 5    | Permission Denied     |
| 6    | Unsupported Operation |

Custom exit codes above 100 may be used by individual modules if documented.

---

# 10.7 Verification Contract

Every module shall provide automated verification.

Verification shall confirm:

* Required packages
* Required services
* Configuration validity
* Required ports
* Required files
* Required permissions
* Service status

Verification must never modify the system.

Verification scripts are read-only.

---

# 10.8 Reporting Contract

Each module shall contribute to the framework status report.

Minimum report fields:

```text
Module Name

Version

Status

Installed

Configured

Verified

Last Updated

Dependencies

Health
```

The report shall be machine-readable (JSON or YAML) and optionally rendered as Markdown or HTML for human consumption.

---

# 10.9 Configuration Contract

Modules shall never contain hardcoded user-specific values.

Configuration sources shall follow this precedence:

1. Environment Variables
2. `.env`
3. YAML Configuration
4. Module Defaults

If required configuration is missing, the module shall fail with a clear error message.

---

# 10.10 Dependency Contract

Every module shall declare:

* Required modules
* Optional modules
* Conflicting modules

The framework shall validate dependencies before execution.

Circular dependencies are prohibited.

Example:

```text
docker

requires

common
```

```text
k3s

requires

docker

network

storage
```

---

# 10.11 Documentation Contract

Every module shall include a `README.md` containing:

* Purpose
* Features
* Dependencies
* Installation
* Configuration
* Verification
* Removal
* Backup
* Restore
* Troubleshooting
* Release Notes

No module is considered complete without documentation.

---

# 10.12 Testing Contract

Every module shall include automated tests.

Minimum required tests:

* Smoke Test
* Installation Test
* Verification Test
* Removal Test

Recommended:

* Integration Test
* Performance Test
* Recovery Test

Tests shall execute non-interactively.

---

# 10.13 Security Contract

Modules shall adhere to the following security requirements:

* Principle of least privilege
* Validate all inputs
* Never store secrets in source code
* Support non-interactive execution
* Produce auditable logs
* Use official package repositories whenever possible
* Verify downloads where checksums or signatures are available

---

# 10.14 Extensibility Contract

A new module shall be installable without modifying the framework core.

Adding a module shall require only:

* Bash scripts
* Ansible role
* Configuration template
* Documentation
* Tests
* Registration in the Makefile

The framework itself shall not require architectural changes to support future modules.

---

# 10.15 Framework Guarantee

Any module that satisfies this contract is considered a first-class framework component.

The framework guarantees that compliant modules can be:

* Installed
* Configured
* Verified
* Reported
* Updated
* Removed

using the same commands and lifecycle as every other module.

This contract forms the public API of the Homelab Framework and is intended to remain stable across future releases unless a major version introduces breaking architectural changes.

---

# 11. Testing Requirements

Every module shall provide:

Install

Configure

Verify

Remove

Smoke tests required.

Unit tests encouraged.

Integration tests for infrastructure modules.

---

# 12. Versioning Strategy

Semantic Versioning.

```
MAJOR.MINOR.PATCH
```

Examples

```
1.0.0

1.1.0

1.1.2

2.0.0
```

Rules:

Major

Breaking architecture

Minor

New functionality

Patch

Bug fixes

---

# 13. Release Workflow

Development

↓

Feature Branch

↓

Testing

↓

Release Candidate

↓

Version Tag

↓

Production Release

Every release updates:

VERSION

CHANGELOG.md

Release Notes

---

# 14. Documentation Requirements

Every module shall include:

Purpose

Dependencies

Installation

Configuration

Verification

Troubleshooting

Removal

---

# 15. Extensibility

The framework is designed to support future modules without architectural changes.

Future modules may include:

* Kubernetes
* Docker Swarm
* Proxmox
* Virtual Machines
* Monitoring
* GitOps
* Storage
* Backup
* AI Services
* Home Automation
* Security
* CI/CD

New modules must conform to this specification.

---

# 16. Guiding Principles

The framework shall remain:

* Open
* Reproducible
* Portable
* Modular
* Observable
* Recoverable
* Well documented
* Easy to maintain

Automation is preferred over manual intervention.

Reproducibility is preferred over convenience.

Simplicity is preferred over unnecessary complexity.

Documentation is considered part of the implementation.

No feature is complete until it is documented and verifiable.
