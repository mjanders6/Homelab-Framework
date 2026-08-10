# Changelog

## 2.4.0
- Completed Sprint 4: removed the legacy network-boot/bootserver path, hardened the rebuild flow, and finalized rebuild-first recovery steps.
- Cleaned up stale K3s troubleshooting references and finalized Sprint 3 migration work.
- Bumped the repository version to `2.4.0`.

## 2.3.0
 - Completed Sprint 2 by implementing the rebuild-first workflow and retiring legacy bootserver/PXE/K3s automation.
 - Added a command-node CLI menu entrypoint for bootstrap, rebuild, playbook, and environment workflows.
 - Updated documentation to reflect the new post-install automation flow and command-node usage.

## 2.2.0
- Bumped the framework version for the next release cycle.
- Completed Sprint 1 by implementing a first version of the image-based foundation for rebuilds.
- Added a role-to-image mapping workflow, image artifact build and packaging flow, validation checklist, and smoke tests.
- Wired the image workflow validation into CI so the new path is exercised automatically.
- Continued the rebuild-first migration by documenting and promoting the new automation path.
- Preserved the phased retirement of the network-boot approach in the project guidance and release notes.

## 2.1.0
- Updated GitHub repository metadata for the rebuild-first workflow.
- Added repository instructions and CI workflow scaffolding.
- Set the repository CODEOWNER to @mjanders6.
- Began phasing out the network-boot and bootserver-based workflow by promoting rebuild-first automation as the supported path.
- Began phasing out the K3s-centric deployment approach in favor of the newer rebuild-first model.

## 2.0.0 Sprint 2
- Updated framework version for Sprint 2.
- Added hybrid Raspberry Pi bootserver module with per-node boot directories.

## 1.0.0 Foundation
- Initial framework.
