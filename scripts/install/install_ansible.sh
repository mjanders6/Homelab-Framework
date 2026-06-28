#!/usr/bin/env bash
set -e

sudo apt update

sudo apt install -y \
    ansible \
    sshpass

ansible --version
