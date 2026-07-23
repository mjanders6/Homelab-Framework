# Image workflow

This directory contains the implemented Sprint 1 image build and storage workflow.

## Layout

Images are stored under the repository's images directory using this structure:

- images/<role>/v<version>/<image-name>-<version>.tar.gz
- images/<role>/v<version>/manifest.json
- images/<role>/v<version>/metadata.json
- images/<role>/v<version>/staging/staged-base.img

## Current behavior

The build script stages a base Ubuntu image source, records build metadata, and packages the staged image plus manifest into a versioned tarball. This is now the completed Sprint 1 foundation for the rebuild-first workflow and provides a deterministic image build path that can later be expanded into a full OS image pipeline.

## Validation checklist

Before considering an image build complete, verify the following:

- A base Ubuntu image source is provided or resolved by default.
- The staged image is verified against a supplied checksum when available.
- The packaged artifact contains the staged image and manifest.
- The manifest and metadata files are written under the role/version directory.
- The artifact name and version follow the role-image-version convention.
