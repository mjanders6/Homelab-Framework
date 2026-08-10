# Sprint 4 — Remove the Old Path and Harden Recovery

## Goal

Finish the migration by removing the old network-boot-based path from the default workflow and making the new rebuild flow the primary supported experience.

## Scope

This sprint focuses on cleanup, documentation, and recovery readiness.

## Outcomes

- Retire or deprecate the old bootserver approach from the main workflow.
- Update the framework documentation to reflect the new rebuild model.
- Ensure a full recovery path exists for reinstalling a node and returning it to service.

## Deliverables

- Updated README and architecture docs.
- Clear rebuild instructions for end users.
- A tested end-to-end recovery run for at least one representative node.

## Suggested Tasks

- Remove or mark deprecated any bootserver-specific entry points in the default flow.
- Update docs and examples to show the new image-first process.
- Add recovery steps for failed or partial rebuilds.
- Validate the full workflow from reinstall to full service restoration.

## Success Criteria

- The framework supports rebuilding a node without network booting.
- The documentation matches the implementation.
- The rebuild path is simple enough to use repeatedly.

## Status

Sprint 4 — Completed: the legacy network-boot/bootserver path has been retired from the main workflow, documentation has been updated, and rebuild recovery guidance has been added to the repository.
