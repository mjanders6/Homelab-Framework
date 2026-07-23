# Image build validation checklist

Use this checklist to verify the completed Sprint 1 image workflow for a role:

- [ ] The role maps to a known image variant.
- [ ] The build uses an Ubuntu-compatible base image source.
- [ ] The base image source is verified with a checksum when provided.
- [ ] The artifact is written under the expected role/version directory.
- [ ] The packaged tarball contains the staged image and manifest.
- [ ] The manifest records the role, image name, version, and artifact path.
- [ ] The metadata file records the build timestamp and source details.
