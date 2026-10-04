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

## Setup

Ansible must run on a Linux control node (Ubuntu, a Pi, or WSL; not native Windows):

```bash
make setup                          # installs Ansible, checks for an SSH key
ssh-copy-id <user>@<host>           # once per host; users come from the inventory
make run PLAYBOOK=ping HOST=all     # verify connectivity
```

For playbooks that need sudo, add `--ask-become-pass` (`-K`) or configure passwordless sudo on the target. The CLI sets `ANSIBLE_CONFIG` to the repo's `ansible.cfg`, so it works from any directory. On WSL, keep the repo in the Linux filesystem (e.g. `~/`): Ansible ignores config in world-writable `/mnt/c` paths, and SSH key permissions can't be enforced there.

## Adding hosts and playbooks

- Add hosts to `ansible/inventories/lab/hosts.yml` under the `lab` group.
- Add a playbook as `ansible/playbooks/<name>.yml` with `hosts: all`; it is picked up automatically.

Included playbooks: `ping`, `bootstrap`, `update`.

## Environment

Defaults are loaded from `.env` and `scripts/lib/env.sh`. The menu can persist variables to `.env` and pass them as extra vars for the session.
