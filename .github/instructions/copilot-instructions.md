# Copilot Instructions for HomeLab Framework

## Repository purpose
HomeLab Framework is an Ansible-based infrastructure automation repository for provisioning and managing homelab systems. Prioritize reliability, idempotency, and documentation quality.

## General guidelines
- Prefer minimal, well-documented changes.
- Keep shell scripts portable and POSIX-friendly where possible.
- Preserve existing Ansible structure and naming conventions.
- Favor idempotent automation and safe defaults.
- When modifying infrastructure logic, update related documentation and module metadata.

## Versioning
- The current project version is 2.0.0.
- Keep version references consistent across documentation and release-related files.

## Ownership
- Primary repository owner: @mjanders6
- Changes to infrastructure, automation, and GitHub automation should be reviewed by the owner.

## Preferred change patterns
- Use descriptive variable names and comments in shell and YAML files.
- Add or update tests when changing behavior in scripts or playbooks.
- Avoid introducing unnecessary dependencies.
- Keep secrets out of repository content.
