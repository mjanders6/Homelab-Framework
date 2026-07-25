# Sprint 0 — Define the New Rebuild Path

## Goal

Remove the dependency on network booting from the Homelab Framework and replace it with a simpler rebuild flow based on local images and post-install automation.

## Scope

This sprint focuses on planning and design only. No implementation changes are required yet.

## Outcomes

- Document the current bootserver/PXE approach and why it is being replaced.
- Define the target architecture for a rebuild flow that does not rely on network boot.
- Decide which node types will use which base images.
- Identify the first automation steps that will run after reinstalling an OS.

## Deliverables

- A short architecture note describing the new rebuild model.
- A list of supported node roles and their expected image or install path.
- A backlog of the first implementation tasks for Sprint 1.

## Suggested Questions to Answer

- What is the minimum path to reinstall a node and get it back to a usable state?
- Should the rebuild start from a prebuilt image or from a standard installer plus bootstrap?
- Which services must be restored first after reinstall?
- What should be automated versus manually handled during the first pass?

## Success Criteria

- The team agrees on the replacement approach for network booting.
- The next sprint has a clear implementation plan.
- The project direction is documented in the repository.
