##############################################################################
# Home Lab Setup — Makefile
##############################################################################

SHELL := /bin/bash

SCRIPT_DIR := ./scripts

##############################################################################
# Help
##############################################################################

help: ## Show this help message
	@echo "Usage: make <target>"
	@echo ""
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} \
	/^[a-zA-Z_-]+:.*?## / { \
	printf "  %-25s %s\n", $$1, $$2 \
	}' $(MAKEFILE_LIST)

##############################################################################
# Full Deployment
##############################################################################

all: pi5 pi4_network pi4_monitor pi4_backup desktop ## Run all node setups

##############################################################################
# Base Setup
##############################################################################

base: ## Install common packages/directories
	@echo "🔧 Installing common packages..."
	bash $(SCRIPT_DIR)/install/common_packages.sh

	@echo "🔧 Creating common directories..."
	bash $(SCRIPT_DIR)/configure/setup_directories.sh

##############################################################################
# Raspberry Pi 5
##############################################################################

pi5: base ## Setup Raspberry Pi 5 application node
	@echo "🔧 Setting up Raspberry Pi 5..."

	bash $(SCRIPT_DIR)/install/install_docker.sh
	bash $(SCRIPT_DIR)/install/install_cockpit.sh
	bash $(SCRIPT_DIR)/install/install_ansible.sh
	bash $(SCRIPT_DIR)/configure/setup_ansible_directories.sh

##############################################################################
# Raspberry Pi 4 — Networking
##############################################################################

pi4_network: base ## Setup Raspberry Pi 4 networking node
	@echo "🔧 Setting up Raspberry Pi 4 networking node..."

	bash $(SCRIPT_DIR)/install/install_docker.sh
	bash $(SCRIPT_DIR)/install/install_tailscale.sh
	bash $(SCRIPT_DIR)/install/install_cockpit.sh

	# Optional:
	# bash $(SCRIPT_DIR)/install/install_pihole.sh

##############################################################################
# Raspberry Pi 4 — Monitoring
##############################################################################

pi4_monitor: base ## Setup Raspberry Pi 4 monitoring node
	@echo "🔧 Setting up Raspberry Pi 4 monitoring node..."

	bash $(SCRIPT_DIR)/install/install_docker.sh
	bash $(SCRIPT_DIR)/install/install_node_exporter.sh
	bash $(SCRIPT_DIR)/install/install_cockpit.sh

##############################################################################
# Raspberry Pi 4 — Backup Node
##############################################################################

pi4_backup: base ## Setup Raspberry Pi 4 backup node
	@echo "🔧 Setting up Raspberry Pi 4 backup node..."

	bash $(SCRIPT_DIR)/install/install_docker.sh
	bash $(SCRIPT_DIR)/install/install_restic.sh

	# Samba
	bash $(SCRIPT_DIR)/install/install_samba.sh
	bash $(SCRIPT_DIR)/configure/configure_samba_shares.sh

	# Management
	bash $(SCRIPT_DIR)/install/install_cockpit.sh
	# Optional:
	# bash $(SCRIPT_DIR)/install/install_webmin.sh

##############################################################################
# Desktop: This is the Infrastructure Server for the Home Lab
##############################################################################

desktop: base ## Setup desktop as the Infrastructure Server for the Home Lab
	@echo "🔧 Setting up desktop storage/media node..."

	# Samba
	bash $(SCRIPT_DIR)/install/install_samba.sh
	bash $(SCRIPT_DIR)/configure/configure_samba_shares.sh

	# Server Management:
	bash $(SCRIPT_DIR)/install/install_webmin.sh

##############################################################################
# Individual Services
##############################################################################

docker: ## Install Docker
	@echo "🔧 Installing Docker..."
	bash $(SCRIPT_DIR)/install/install_docker.sh

tailscale: ## Install Tailscale
	@echo "🔧 Installing Tailscale..."
	bash $(SCRIPT_DIR)/install/install_tailscale.sh

##############################################################################
# Samba
##############################################################################

samba: ## Install Samba packages
	@echo "🔧 Installing Samba..."
	bash $(SCRIPT_DIR)/install/install_samba.sh

samba-config: ## Configure Samba shares/directories
	@echo "🔧 Configuring Samba shares..."
	bash $(SCRIPT_DIR)/configure/configure_samba_shares.sh

##############################################################################
# Backup / Monitoring
##############################################################################

restic: ## Install Restic
	@echo "🔧 Installing Restic..."
	bash $(SCRIPT_DIR)/install/install_restic.sh

monitoring: ## Install Node Exporter
	@echo "🔧 Installing monitoring tools..."
	bash $(SCRIPT_DIR)/install/install_node_exporter.sh

##############################################################################
# Media
##############################################################################

jellyfin: ## Install Jellyfin
	@echo "🔧 Installing Jellyfin..."
	bash $(SCRIPT_DIR)/install/install_jellyfin.sh

##############################################################################
# Management
##############################################################################

cockpit: ## Install Cockpit
	@echo "🔧 Installing Cockpit..."
	bash $(SCRIPT_DIR)/install/install_cockpit.sh

remove-cockpit: ## Remove Cockpit
	@echo "🔧 Removing Cockpit..."
	bash $(SCRIPT_DIR)/cleanup/remove_cockpit.sh

webmin: ## Install Webmin
	@echo "🔧 Installing Webmin..."
	bash $(SCRIPT_DIR)/install/install_webmin.sh

##############################################################################
# Automation
##############################################################################

ansible: ## Install Ansible
	@echo "🔧 Installing Ansible..."
	bash $(SCRIPT_DIR)/install/install_ansible.sh

ansible-dirs: ## Setup Ansible directories
	@echo "🔧 Setting up Ansible directories..."
	bash $(SCRIPT_DIR)/configure/setup_ansible_directories.sh

##############################################################################
# Cleanup
##############################################################################

clean: ## Remove temporary files
	@echo "🔧 Cleaning temporary files..."

	rm -rf /tmp/node_exporter*

##############################################################################
# Phony Targets
##############################################################################

.PHONY: \
	help \
	all \
	base \
	pi5 \
	pi4_network \
	pi4_monitor \
	pi4_backup \
	desktop \
	docker \
	tailscale \
	samba \
	samba-config \
	restic \
	monitoring \
	jellyfin \
	cockpit \
	remove-cockpit \
	webmin \
	ansible \
	ansible-dirs \
	clean