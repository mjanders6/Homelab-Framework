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
	@python3 $(SCRIPT_DIR)/lib/help.py # @python3 worked for Ubuntu Server 24.04
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

cli: ## Launch the interactive Homelab command node CLI
	@bash $(SCRIPT_DIR)/cli/homelab-cli.sh

##############################################################################
# Framework module targets
##############################################################################
define MODULE_ACTION_TEMPLATE
$(1)-%: ## Run $(1) action on a module
	@bash $(SCRIPT_DIR)/lib/modules.sh run $(1) $$*
endef

$(foreach action,$(MODULE_ACTIONS),$(eval $(call MODULE_ACTION_TEMPLATE,$(action))))

##############################################################################
# Ansible runs (v3.0.0): any playbook against any host
##############################################################################

HOST ?=
PLAYBOOK ?=
CHECK ?=

run: ## Run an Ansible playbook on a host (make run PLAYBOOK=bootstrap HOST=rpi1 [CHECK=1])
	@test -n "$(PLAYBOOK)" -a -n "$(HOST)" || { echo "Usage: make run PLAYBOOK=<playbook> HOST=<host|group|all> [CHECK=1]"; exit 1; }
	@bash $(SCRIPT_DIR)/cli/homelab-cli.sh run "$(PLAYBOOK)" --host "$(HOST)" $(if $(CHECK),--check)

setup: ## Install/verify Ansible on this command node
	@bash $(SCRIPT_DIR)/cli/homelab-cli.sh setup

hosts: ## List inventory hosts
	@bash $(SCRIPT_DIR)/cli/homelab-cli.sh hosts

playbooks: ## List available playbooks
	@bash $(SCRIPT_DIR)/cli/homelab-cli.sh playbooks

##############################################################################
# Base Setup
##############################################################################

base: ## Install common packages/directories
	@echo "🔧 Installing common packages..."
	bash $(SCRIPT_DIR)/install/common_packages.sh

	@echo "🔧 Creating common directories..."
	bash $(SCRIPT_DIR)/configure/setup_directories.sh

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

monitoring: ## Install Node Exporter
	@echo "🔧 Installing monitoring tools..."
	bash $(SCRIPT_DIR)/install/install_node_exporter.sh

##############################################################################
# Media
##############################################################################

##############################################################################
# Management
##############################################################################

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
	base \
	run \
	setup \
	hosts \
	playbooks \
	docker \
	tailscale \
	samba \
	samba-config \
	monitoring \
	webmin \
	ansible \
	ansible-dirs \
	cli \
	clean