# Homelab Framework CLI

This page describes the new command-node CLI entrypoint for the Homelab Framework.

## Launching the CLI

Start the interactive CLI from the repository root:

```bash
make cli
```

This runs `scripts/cli/homelab-cli.sh` and presents a simple menu for common command-node operations.

## Menu options

1) **Bootstrap this command node**
   - Runs the shared bootstrap workflow on the command node.
   - This installs prerequisites and prepares the host for rebuild and automation tasks.

2) **Rebuild a remote role node**
   - Prompts for a role selection and then executes `scripts/rebuild/rebuild-node.sh` remotely.
   - Supported roles include `desktop`, `pi5`, `pi4_network`, `pi4_monitor`, and `pi4_backup`.
   - You can choose a dry-run mode to print the rebuild role without making changes.

3) **Run Ansible playbook**
   - Prompts for an available playbook and runs it with `ansible-playbook`.
   - Current options are `bootstrap`, `desktop`, and `infrastructure`.
   - Additional extra variables can be supplied via the CLI environment menu.

4) **Set environment variable**
   - Adds an Ansible extra variable for the current CLI session.
   - Example: `-e KEY=value` is appended to the playbook run.

5) **Print current environment**
   - Displays the active environment values loaded from `.env` and the network defaults.
   - Helpful for confirming node addresses and network settings before running automation.

6) **Exit**
   - Closes the interactive CLI session.

## Notes

- The CLI is intended for the command-node / management host, where the framework can orchestrate rebuilds and bootstrap workflows.
- Environment defaults are loaded from `.env` and `scripts/lib/env.sh`.
- This interactive menu replaces older network boot and PXE-based command-node workflows with a simpler rebuild-first experience.
