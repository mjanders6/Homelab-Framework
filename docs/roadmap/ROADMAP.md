# Roadmap

Version 3.0.0 resets the framework to a simple, role-free core. Every host in the
inventory is treated the same; behavior is selected by the playbook you run, not by a
host role.

## 3.0.0
- Single `lab` inventory group; no per-host roles.
- Generic playbooks: `ping`, `bootstrap`, `update`.
- CLI runs any playbook against any host: `homelab-cli.sh run <playbook> --host <host>`.

## Next
- Add more generic playbooks (docker, nfs, logging) driven by variables.
- Retire the legacy role-based rebuild scripts and role images.
