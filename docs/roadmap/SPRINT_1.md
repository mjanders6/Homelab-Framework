# Sprint 1 — Build the Image-Based Foundation

## Goal

Create a repeatable, versioned image workflow for each homelab node role so reinstalling a machine can start from a known base image rather than network boot.

## Scope

This sprint focuses on building the base image path.

## Outcomes

- Define the base image strategy for each node type.
- Create a repeatable build process for Ubuntu-based images.
- Prepare the image for basic provisioning needs such as SSH, hostname defaults, and common packages.
- Version and store images in a predictable location.

## Deliverables

- Image build script or documented build process.
- List of supported node roles and image variants.
- Basic image validation checklist.

## Suggested Tasks

- Choose the base OS image and tooling.
- Create a simple image build pipeline.
- Document image naming and versioning.
- Validate that the image boots correctly and reaches the first automation step.

## Success Criteria

- A fresh image can be built repeatedly with the same process.
- The image is suitable as the starting point for a rebuilt node.
- The next sprint can use the image as the input to bootstrap automation.
