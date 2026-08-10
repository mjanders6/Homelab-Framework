# Sprint 2 — Replace First-Boot Automation

## Goal

Move the current first-boot automation out of the bootserver workflow and into a normal post-install bootstrap flow.

## Scope

This sprint focuses on making reinstall-driven setup work without PXE or TFTP.

## Outcomes

- Define the bootstrap sequence that runs after a node is installed from an image.
- Reuse the existing Ansible and script-based automation where possible.
- Ensure the bootstrap flow is idempotent and safe to re-run.

## Deliverables

- [x] A documented bootstrap workflow for a newly installed node.
- [x] Updated inventory or role selection for the new path.
- [x] A verified command or script that performs the first automation pass.
- [x] A command-node CLI entrypoint for rebuild and playbook orchestration.

## Status

Sprint 2 is complete. The command-node CLI and rebuild-first post-install workflow have been implemented, and legacy bootserver/K3s automation has been retired.

## Suggested Tasks

- Identify which existing automation steps can run after the OS is installed.
- Split the current bootserver logic into install-time and post-install tasks.
- Make the bootstrap safe to re-run after a failed or partial setup.
- Validate the flow on a test node.

## Success Criteria

- A node can be rebuilt from an image and then configured through automation.
- The bootstrap process can be repeated without creating duplicate or conflicting state.
- The workflow is ready to support service modules in the next sprint.
