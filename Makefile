##############################################################################
# Home Lab Setup — Makefile
##############################################################################

SHELL := /bin/bash

SCRIPT_DIR := ./scripts
MODULE_ACTIONS := install configure verify status remove backup restore update upgrade report
MODULES := $(shell bash $(SCRIPT_DIR)/lib/modules.sh list_modules)

##############################################################################
# Help
##############################################################################

help: ## Show this help message
	@echo ""
	@echo "Home Lab Framework"
	@echo "=================="
	@echo ""
	@echo "Usage:"
	@echo "  make <target>"
	@echo ""
	@echo "Standard Targets"
	@echo "----------------"
	@python $(SCRIPT_DIR)/lib/help.py # @python worked while @python3 did not.
	@echo ""
	@echo "Framework Module Commands"
	@echo "-------------------------"
	@for action in $(MODULE_ACTIONS); do \
		printf "  %-30s Run '$$action' on a module\n" "$$action-<module>"; \
	done
	@echo ""
	@echo "Available Modules"
	@echo "-----------------"
	@bash $(SCRIPT_DIR)/lib/modules.sh list_modules
	
modules: ## List available framework modules
	@bash $(SCRIPT_DIR)/lib/modules.sh list_modules

module-help: ## Show help for module discovery and framework status
	@echo "Framework Help"
	@bash $(SCRIPT_DIR)/lib/framework.sh framework_help

module-status: ## Run status on all discovered modules
	@bash $(SCRIPT_DIR)/lib/framework.sh framework_status

install-dependencies-k3s: ## Install dependencies for the k3s module without running k3s itself
	@bash $(SCRIPT_DIR)/lib/modules.sh run install k3s

deps-k3s: ## Show dependency resolution order for k3s
	@bash $(SCRIPT_DIR)/lib/modules.sh deps k3s

diagnose-k3s: ## Diagnose k3s module metadata and lifecycle scripts
	@bash $(SCRIPT_DIR)/lib/modules.sh diagnose k3s

##############################################################################
# Framework module targets
##############################################################################
define MODULE_ACTION_TEMPLATE
$(1)-%: ## Run $(1) action on a module
	@bash $(SCRIPT_DIR)/lib/modules.sh run $(1) $$*
endef

$(foreach action,$(MODULE_ACTIONS),$(eval $(call MODULE_ACTION_TEMPLATE,$(action))))

##############################################################################
# Full Deployment
##############################################################################

all: pi5 pi4_network pi4_monitor pi4_backup desktop ## Run all node setups

rebuild-%: ## Rebuild a node from a fresh OS install using the bootstrap flow
	@bash $(SCRIPT_DIR)/rebuild/rebuild-node.sh $*

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
# Rebuild Workflow
##############################################################################

rebuild-default: base ## Start the rebuild flow for a fresh node install
	@echo "🔧 Starting default rebuild flow..."
	bash $(SCRIPT_DIR)/rebuild/rebuild-node.sh default

rebuild-desktop: base ## Rebuild the desktop/infrastructure host
	@echo "🔧 Starting desktop rebuild flow..."
	bash $(SCRIPT_DIR)/rebuild/rebuild-node.sh desktop

rebuild-pi5: base ## Rebuild a Raspberry Pi 5 node
	@echo "🔧 Starting Pi 5 rebuild flow..."
	bash $(SCRIPT_DIR)/rebuild/rebuild-node.sh pi5

rebuild-pi4-network: base ## Rebuild a Raspberry Pi 4 networking node
	@echo "🔧 Starting Pi 4 networking rebuild flow..."
	bash $(SCRIPT_DIR)/rebuild/rebuild-node.sh pi4_network

rebuild-pi4-monitor: base ## Rebuild a Raspberry Pi 4 monitoring node
	@echo "🔧 Starting Pi 4 monitoring rebuild flow..."
	bash $(SCRIPT_DIR)/rebuild/rebuild-node.sh pi4_monitor

rebuild-pi4-backup: base ## Rebuild a Raspberry Pi 4 backup node
	@echo "🔧 Starting Pi 4 backup rebuild flow..."
	bash $(SCRIPT_DIR)/rebuild/rebuild-node.sh pi4_backup

image-%: ## Build a role-specific image artifact for Sprint 1 testing
	@bash $(SCRIPT_DIR)/images/build-role-image.sh $* $(VERSION)

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
	bootserver \
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