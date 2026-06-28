#!/usr/bin/env bash

##############################################################################
#
# Home Lab Setup — Install Restic on the system for backup purposes
#
##############################################################################

set -e

sudo apt update
sudo apt install -y restic rsync
