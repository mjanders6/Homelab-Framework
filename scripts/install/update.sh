#!/usr/bin/env bash
set -e
sudo apt update && sudo apt -y upgrade
sudo apt -y install curl wget make build-essential python3 python3-pip
