# Sprint 0 Implementation Notes

## Current progress

A first rebuild entrypoint has been added at [scripts/rebuild/rebuild-node.sh](scripts/rebuild/rebuild-node.sh).

This script provides a simple starting point for reinstall-driven setup by:

- running the bootstrap flow,
- accepting a role name,
- and printing the next steps for the selected node role.

## Why this matters

This is the first step away from the old bootserver-first mindset and toward a simpler rebuild model:

1. reinstall the OS,
2. run the rebuild script,
3. continue with the role-specific automation.

## Next step

The next implementation step is to wire this script into the main Makefile and document it in the project readme.
