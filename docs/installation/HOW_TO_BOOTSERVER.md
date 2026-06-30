# How to create a golden image, build a boot server, and boot Raspberry Pis from it

This short guide shows the simplest path for using the bootserver workflow in this repository.

## 1. Prepare the bootserver host

1. Install the base tools on the desktop/infrastructure host:

```bash
make base
```

2. Install the bootserver module:

```bash
make install-bootserver
```

3. Configure the Docker-based bootserver stack:

```bash
make configure-bootserver
```

This starts the TFTP and nginx containers so the host can serve boot assets over the network.

## 2. Define the Raspberry Pi nodes

Edit the node map in [ansible/group_vars/bootserver_mac_ip_map.yml](../../ansible/group_vars/bootserver_mac_ip_map.yml) and set one entry per Raspberry Pi.

Each entry should contain:

- `mac`: the Pi MAC address
- `ip`: the static IP for that Pi
- `gateway`: the network gateway
- `nameservers`: DNS servers
- `packages`: packages to install on first boot
- `runcmd`: commands to run after the first boot

Example:

```yaml
pi5:
  mac: "dc:a6:32:aa:bb:cc"
  ip: "192.168.1.51"
  gateway: "192.168.1.1"
  nameservers:
    - "192.168.1.1"
  packages:
    - docker.io
    - curl
    - jq
  runcmd:
    - "curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC=\"server --write-kubeconfig-mode 644\" sh -"
```

## 3. Generate the golden image boot assets

Run this to render the per-node `meta-data`, `user-data`, `network-config`, and `vendor-data` files into `/srv/tftp/boot/<node>`:

```bash
make build-golden-image
```

If you want the bootserver to also run K3s for the cluster, install it with:

```bash
make bootserver-k3s
```

## 4. Put the Raspberry Pis on the network

1. Enable PXE/network boot in each Raspberry Pi firmware.
2. Connect each Pi to the same network as the bootserver.
3. Make sure the static IPs in [ansible/group_vars/bootserver_mac_ip_map.yml](../../ansible/group_vars/bootserver_mac_ip_map.yml) match your subnet.
4. Boot the Pi.

The Pi will:

1. PXE boot from the bootserver
2. Load the kernel and initramfs from TFTP
3. Apply the cloud-init configuration from `/srv/tftp/boot/<node>/`
4. Use the assigned static IP and run any first-boot commands you configured

## 5. Verify the bootserver and the Pi state

Check the bootserver containers:

```bash
make verify-bootserver
```

Check the generated boot assets:

```bash
ls -la /srv/tftp/boot/
```

After the Pi finishes booting, verify that:

- the expected static IP is assigned
- the listed packages were installed
- the node-specific commands ran
- the K3s server or agent joined as expected

## 6. Repeat for a new Raspberry Pi image

When you need a new profile:

1. Update the node entry in [ansible/group_vars/bootserver_mac_ip_map.yml](../../ansible/group_vars/bootserver_mac_ip_map.yml)
2. Run:

```bash
make build-golden-image
```

3. Reboot the Pi to apply the new golden image profile
