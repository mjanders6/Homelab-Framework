# Sprint 1 — Completed: Build the Image-Based Foundation

## Goal

Create a repeatable, versioned image workflow for each homelab node role so reinstalling a machine can start from a known base image rather than network boot.

## Status

Completed. The framework now includes a first-pass image build and storage workflow for role-based rebuilds.

## Scope

This sprint focused on building the base image path and validating that it is repeatable enough to support the next stage of automation.

## Outcomes

- Defined the base image strategy for the supported role mapping flow.
- Created a repeatable build process for Ubuntu-based image artifacts.
- Added image packaging, manifest generation, metadata capture, and validation guidance.
- Versioned and stored role-based image artifacts in a predictable location.

## Deliverables

- Image build script and documented build process.
- Role-to-image mapping in the rebuild workflow.
- Basic image validation checklist.
- A repeatable storage layout for role-based image artifacts.
- CI coverage for the image workflow smoke test.

## Completed Tasks

- Formalized the role-to-image mapping in the rebuild workflow.
- Added a simple image build pipeline with artifact packaging.
- Documented image naming and versioning conventions.
- Added validation checks for manifest, metadata, and artifact contents.
- Wired the validation flow into CI.

## Success Criteria

- A fresh image artifact can be built repeatedly with the same process.
- The image workflow is suitable as the starting point for a rebuilt node.
- The next sprint can use the image workflow as the input to further bootstrap automation.
