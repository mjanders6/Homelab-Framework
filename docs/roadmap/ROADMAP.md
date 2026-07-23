## Plan: Replace network boot with image-based rebuilds

The current framework is centered on a hybrid PXE/cloud-init bootserver flow in [README.md](README.md) and the bootserver module in [modules/bootserver/README.md](modules/bootserver/README.md). To remove that dependency while keeping fast rebuilds, the migration should shift to a local-image and post-install automation model.

### Recommended sprint structure

1. Sprint 0 — Baseline and target architecture
   - Audit the current bootserver workflow, dependencies, and assumptions.
   - Define the target architecture: boot from local media or a prebuilt image, then run automation over the network.
   - Decide which node roles will use which images and what bootstrap data each one needs.
   - Deliverables: architecture decision record, updated repo roadmap, explicit scope for removing PXE/TFTP from the supported path.

2. Sprint 1 — Build a golden-image workflow
   - Create a repeatable image-build path for each node type using Ubuntu Server as the base.
   - Bake in basic identity, SSH access, hostname defaults, and required packages into the image.
   - Store images in a controlled location and version them with the repo or a release artifact store.
   - Deliverables: image build scripts, documented image naming/versioning, one tested image per primary node type.

3. Sprint 2 — Replace first-boot automation with a local bootstrap flow
   - Introduce a bootstrap workflow that runs after the node is installed from the image.
   - Reuse the existing Ansible playbooks and module lifecycle model under [ansible](ansible) and [scripts](scripts), but remove any hard dependency on the bootserver module.
   - Make the flow idempotent so reinstalling a node produces the same final state.
   - Deliverables: one-button bootstrap command, inventory updates, validation steps for a fresh install.

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
