#
# modules/siyuan/Makefile
#
# NOTE: the framework already dispatches this module from the repo root via
# `make install-siyuan`, `make configure-siyuan`, `make verify-siyuan`,
# `make status-siyuan`, `make remove-siyuan` (see the root Makefile's
# MODULE_ACTION_TEMPLATE + scripts/lib/modules.sh). The targets below just
# delegate to that rather than reimplementing it, and add a few things the
# framework's module-action model doesn't cover: raw docker compose
# lifecycle and SiYuan-specific data operations.
#

SHELL := /usr/bin/env bash

MODULE_DIR   := $(shell cd "$(dir $(lastword $(MAKEFILE_LIST)))" && pwd)
ROOT_DIR     := $(shell cd "$(MODULE_DIR)/../.." && pwd)
COMPOSE_FILE := /opt/homelab/siyuan/docker-compose.yml

# Read from the repo's .env when present; these are just fallbacks for the
# targets below that shell out directly (export-md, backup).
SIYUAN_PORT             ?= 6806
SIYUAN_CONTAINER_NAME   ?= siyuan
SIYUAN_WORKSPACE_PATH   ?= /srv/samba/siyuan-workspace
SIYUAN_ACCESS_AUTH_CODE ?=

SUDO := $(shell [ "$$(id -u)" -eq 0 ] && echo "" || echo "sudo -E")

.PHONY: help install configure verify status remove \
        up down restart logs export-md backup

help:
	@echo "siyuan module — convenience targets"
	@echo ""
	@echo "  Framework-standard (delegates to repo root):"
	@echo "    make install     -> make install-siyuan"
	@echo "    make configure   -> make configure-siyuan"
	@echo "    make verify      -> make verify-siyuan"
	@echo "    make status      -> make status-siyuan"
	@echo "    make remove      -> make remove-siyuan"
	@echo ""
	@echo "  Raw docker compose lifecycle (not modeled by the framework):"
	@echo "    make up / down / restart / logs"
	@echo ""
	@echo "  Data ops:"
	@echo "    make export-md   -> trigger SiYuan's workspace -> Markdown export"
	@echo "    make backup      -> stop, tar the workspace, restart"

# --- delegate to the framework's own dispatch; don't duplicate its logic ---

install:
	$(SUDO) $(MAKE) -C "$(ROOT_DIR)" install-siyuan

configure:
	$(SUDO) $(MAKE) -C "$(ROOT_DIR)" configure-siyuan

verify:
	$(MAKE) -C "$(ROOT_DIR)" verify-siyuan

status:
	$(MAKE) -C "$(ROOT_DIR)" status-siyuan

remove:
	$(SUDO) $(MAKE) -C "$(ROOT_DIR)" remove-siyuan

# --- raw docker compose lifecycle -------------------------------------------

up:
	$(SUDO) docker compose -f "$(COMPOSE_FILE)" up -d

down:
	$(SUDO) docker compose -f "$(COMPOSE_FILE)" down

restart:
	$(SUDO) docker compose -f "$(COMPOSE_FILE)" restart

logs:
	$(SUDO) docker compose -f "$(COMPOSE_FILE)" logs -f --tail=200

# --- data ops ----------------------------------------------------------------

## Trigger SiYuan's built-in workspace -> Markdown export via its API.
## Output lands under the workspace's own export/ directory.
export-md:
	@curl -fsS -X POST "http://localhost:$(SIYUAN_PORT)/api/export/exportMd" \
		-H "Authorization: Token $(SIYUAN_ACCESS_AUTH_CODE)" \
		-d '{}' \
		&& echo "Export triggered — check the workspace's export/ directory." \
		|| echo "Export request failed — is the container up and the auth code correct?"

## Cold backup: stops the container first, since .sy files aren't guaranteed
## consistent mid-write otherwise.
backup:
	@$(MAKE) --no-print-directory down
	@ts=$$(date +%Y%m%d-%H%M%S); \
	out="/opt/homelab/siyuan/backup-$$ts.tar.gz"; \
	$(SUDO) tar -czf "$$out" -C "$(dir $(SIYUAN_WORKSPACE_PATH))" "$(notdir $(SIYUAN_WORKSPACE_PATH))"; \
	echo "Backup written to $$out"
	@$(MAKE) --no-print-directory up
