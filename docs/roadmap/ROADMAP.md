## Plan: Replace network boot with image-based rebuilds

The current framework is centered on a hybrid PXE/cloud-init bootserver flow in [README.md](README.md) and the bootserver module in [modules/bootserver/README.md](modules/bootserver/README.md). To remove that dependency while keeping fast rebuilds, the migration should shift to a local-image and post-install automation model.

### Status snapshot

- Sprint 0 — Completed: established the rebuild-first target architecture and documented the migration away from the bootserver-centric path.
- Sprint 1 — Completed: implemented the image-based foundation for role-specific rebuilds, including role mapping, artifact packaging, validation checks, and CI coverage.
- Sprint 2 — Completed: replaced first-boot bootserver automation with a local image + post-install bootstrap flow, added the command-node CLI, and retired legacy bootserver/K3s references.
- Future work continues the broader migration away from both the bootserver path and the K3s-centric model, with Sprint 3 focused on infrastructure service migration.

### Recommended sprint structure

1. Sprint 0 — Baseline and target architecture
   - Audit the current bootserver workflow, dependencies, and assumptions.
   - Define the target architecture: boot from local media or a prebuilt image, then run automation over the network.
   - Decide which node roles will use which images and what bootstrap data each one needs.
   - Deliverables: architecture decision record, updated repo roadmap, explicit scope for removing PXE/TFTP from the supported path.

2. Sprint 1 — Completed: Build a golden-image workflow
   - Create a repeatable image-build path for each node type using Ubuntu Server as the base.
   - Bake in basic identity, SSH access, hostname defaults, and required packages into the image.
   - Store images in a controlled location and version them with the repo or a release artifact store.
   - Deliverables: image build scripts, documented image naming/versioning, one tested image per primary node type.

3. Sprint 2 — Completed: Replace first-boot automation with a local bootstrap flow
   - Introduced a bootstrap workflow that runs after the node is installed from the image.
   - Reused existing Ansible playbooks and module lifecycle logic, removing hard dependence on the bootserver module.
   - Made the flow idempotent so reinstalling a node produces the same final state.
   - Added a command-node CLI for bootstrap, rebuild, playbook, and environment workflows.
   - Deliverables: one-button bootstrap command, inventory updates, validation steps for a fresh install, and CLI-based command-node orchestration.

4. Sprint 3 — Migrate infrastructure services to the new path
   - Move core services such as Docker, K3s, networking, logging, NFS, and monitoring onto the new image-plus-bootstrap workflow.
   - Ensure each module can install/configure/verify/remove without PXE support.
   - Keep module boundaries intact so the framework stays modular.
   - Deliverables: updated module scripts, verification coverage, and documented install order.

5. Sprint 4 — Remove the old bootserver path and harden recovery
   - Retire or deprecate the bootserver module from the default workflow and documentation.
   - Update [README.md](README.md), [ARCHITECTURE.md](ARCHITECTURE.md), and the module docs to reflect the new rebuild model.
   - Add recovery steps for reinstalling a node from image and re-running bootstrap.
   - Deliverables: fully documented rebuild path, deprecation notice for PXE/TFTP support, and a tested end-to-end recovery run.

### Scope boundaries
- Keep the goal focused on fast, reproducible rebuilds after OS reinstall.
- Do not expand into a full Kubernetes platform migration in the first pass; the first version should cover the core bootstrap experience.
- Preserve the existing modular structure rather than replacing it with one monolithic script.

### Success criteria
- A node can be reinstalled from a local image without relying on PXE.
- The same automation can complete the post-install configuration in a repeatable way.
- A full rebuild can be executed from a documented sequence in under a reasonable time window.
# Roadmap
