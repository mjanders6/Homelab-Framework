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

2) **Rebuild a remote server node**
   - Prompts for a hostname selection and then executes `scripts/rebuild/rebuild-node.sh` remotely.
   - Supported hostnames include `rpi3-server`, `rpi2-server`, `rpi1-server`, `rpi0-server`, and `tower-server`.
   - The selected hostname is mapped to the appropriate role (`pi5`, `pi4_network`, `pi4_monitor`, `pi4_backup`, or `desktop`).
   - You can choose a dry-run mode to print the rebuild role without making changes.

3) **Install a standalone module on a remote node**
   - Prompts for a module selection and a target hostname.
   - Supported hostnames include `rpi3-server`, `rpi2-server`, `rpi1-server`, `rpi0-server`, and `tower-server`.
   - The CLI installs the selected module on the remote node using `scripts/lib/modules.sh run install <module>`.

4) **Run Ansible playbook**
   - Prompts for an available playbook and runs it with `ansible-playbook`.
   - Current options are `bootstrap`, `desktop`, and `infrastructure`.
   - Additional extra variables can be supplied via the CLI environment menu.

5) **Set environment variable**
   - Persists a variable to the repository `.env` file and adds it as an Ansible extra variable for the current CLI session.
   - Example: `-e KEY=value` is appended to the playbook run.

6) **Print current environment**
   - Displays the active environment values loaded from `.env` and the network defaults.
   - Helpful for confirming node addresses and network settings before running automation.

7) **Exit**
   - Closes the interactive CLI session.

## Notes

- The CLI is intended for the command-node / management host, where the framework can orchestrate rebuilds and bootstrap workflows.
- Environment defaults are loaded from `.env` and `scripts/lib/env.sh`.
- This interactive menu replaces older network boot and PXE-based command-node workflows with a simpler rebuild-first experience.
