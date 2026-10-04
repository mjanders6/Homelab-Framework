# Homelab Framework CLI

Command-node CLI for running Ansible against any host in the inventory. Hosts have no dedicated roles; the playbook you choose defines what happens.

## Usage

```bash
scripts/cli/homelab-cli.sh run <playbook> --host <host> [--check] [-e key=value]
scripts/cli/homelab-cli.sh hosts        # list inventory hosts
scripts/cli/homelab-cli.sh playbooks    # list playbooks in ansible/playbooks
scripts/cli/homelab-cli.sh bootstrap    # bootstrap this command node
make cli                                # interactive menu
```

Example:

```bash
scripts/cli/homelab-cli.sh run bootstrap --host rpi1
scripts/cli/homelab-cli.sh run update --host all --check
```

`--host` accepts an inventory host, a group (`lab`), or `all`. It is passed to `ansible-playbook --limit`. Arguments after `--` go straight to `ansible-playbook`.

## Adding hosts and playbooks

- Add hosts to `ansible/inventories/lab/hosts.yml` under the `lab` group.
- Add a playbook as `ansible/playbooks/<name>.yml` with `hosts: all`; it is picked up automatically.

Included playbooks: `ping`, `bootstrap`, `update`.

## Environment

Defaults are loaded from `.env` and `scripts/lib/env.sh`. The menu can persist variables to `.env` and pass them as extra vars for the session.
