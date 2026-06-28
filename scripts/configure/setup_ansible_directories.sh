#!/usr/bin/env bash
##############################################################################
#
# Home Lab Setup — Set Up Directory Structure for Ansible
#
##############################################################################
set -e

sudo mkdir -p /opt/ansible

sudo mkdir -p /opt/ansible/inventories/production
sudo mkdir -p /opt/ansible/inventories/lab
sudo mkdir -p /opt/ansible/playbooks
sudo mkdir -p /opt/ansible/roles
sudo mkdir -p /opt/ansible/group_vars
sudo mkdir -p /opt/ansible/host_vars

sudo touch /opt/ansible/ansible.cfg

sudo chown -R $USER:$USER /opt/ansible

echo "Ansible directory structure created at /opt/ansible"
