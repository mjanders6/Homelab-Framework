# Sprint 3 — Migrate the Service Modules

## Goal

Move the core homelab services onto the new image-plus-bootstrap workflow so the framework supports a full rebuild without network booting.

## Scope

This sprint focuses on the main service modules that make the homelab usable.

## Outcomes

- Update the core modules so they work without the bootserver dependency.
- Keep the existing modular design intact.
- Ensure install, configure, verify, and remove operations still work in the new model.

## Deliverables

- Updated module documentation for the new workflow.
- Verified support for core services such as Docker, networking, storage, logging, monitoring, or Kubernetes-related services.
- A clear order of operations for bringing services online after a reinstall.

## Suggested Tasks

- Review each module for any bootserver-specific assumptions.
- Replace those assumptions with image-based or post-install execution steps.
- Verify the modules still behave correctly after the change.
- Add notes for any manual steps that remain temporarily necessary.

## Success Criteria

- Core services can be restored using the new rebuild workflow.
- The framework remains modular and repeatable.
- The remaining work is mostly cleanup and hardening.
