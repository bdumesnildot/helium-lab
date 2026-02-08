# ──────────────────────────────────────────────────────────────
#  HeliumLab – Docker Multi-Compose Management
# ──────────────────────────────────────────────────────────────
#  Usage:  make <target>
#
#  Run `make` or `make help` to list available targets.
# ──────────────────────────────────────────────────────────────

SHELL := /bin/bash
.DEFAULT_GOAL := help

# ─── Configuration ────────────────────────────────────────────

DOCKER_DIR     := docker
COMPOSE        := docker compose
COMPOSE_FILE   := docker-compose.yml

# Stacks in boot order (left → right). Shutdown is reversed automatically.
STACKS := docker-utils reverse-proxy auth

# External networks required by the stacks
NETWORKS := docker_socket_proxy traefik_proxy

# ─── Helpers ──────────────────────────────────────────────────

# Reverse a space-separated list
reverse = $(if $(wordlist 2,$(words $(1)),$(1)),$(call reverse,$(wordlist 2,$(words $(1)),$(1))) $(firstword $(1)),$(1))

STACKS_REV := $(call reverse,$(STACKS))

# Build a compose command scoped to a stack directory
# $(1) = stack name
define compose_cmd
	$(COMPOSE) --project-directory $(DOCKER_DIR)/$(1) -f $(DOCKER_DIR)/$(1)/$(COMPOSE_FILE)
endef

# ─── Network Management ──────────────────────────────────────

.PHONY: networks networks-create networks-remove networks-ls

networks: networks-create ## Alias for networks-create

networks-create: ## Create all external Docker networks
	@echo "━━━ Creating external networks ━━━"
	@for net in $(NETWORKS); do \
		if docker network inspect $$net >/dev/null 2>&1; then \
			echo "  ✓ $$net (already exists)"; \
		else \
			docker network create $$net >/dev/null && \
			echo "  + $$net (created)"; \
		fi; \
	done
	@echo ""

networks-remove: ## Remove all external Docker networks
	@echo "━━━ Removing external networks ━━━"
	@for net in $(NETWORKS); do \
		if docker network inspect $$net >/dev/null 2>&1; then \
			docker network rm $$net >/dev/null && \
			echo "  - $$net (removed)"; \
		else \
			echo "  · $$net (not found)"; \
		fi; \
	done
	@echo ""

networks-ls: ## List external networks and their status
	@echo "━━━ External network status ━━━"
	@for net in $(NETWORKS); do \
		if docker network inspect $$net >/dev/null 2>&1; then \
			echo "  ● $$net"; \
		else \
			echo "  ○ $$net (missing)"; \
		fi; \
	done
	@echo ""

# ─── Stack Lifecycle ──────────────────────────────────────────

.PHONY: up down restart pull

up: networks-create ## Start all stacks (in boot order)
	@echo "━━━ Starting all stacks ━━━"
	@for stack in $(STACKS); do \
		echo "  ▶ $$stack"; \
		$(call compose_cmd,$$stack) up -d --remove-orphans || exit 1; \
		echo ""; \
	done

down: ## Stop all stacks (in reverse order)
	@echo "━━━ Stopping all stacks ━━━"
	@for stack in $(STACKS_REV); do \
		echo "  ■ $$stack"; \
		$(call compose_cmd,$$stack) down || true; \
		echo ""; \
	done

restart: down up ## Restart all stacks (down then up)

pull: ## Pull latest images for all stacks
	@echo "━━━ Pulling images ━━━"
	@for stack in $(STACKS); do \
		echo "  ↓ $$stack"; \
		$(call compose_cmd,$$stack) pull; \
		echo ""; \
	done

# ─── Per-Stack Targets ───────────────────────────────────────
# Generates: up-<stack>, down-<stack>, restart-<stack>,
#            pull-<stack>, logs-<stack>, ps-<stack>

define STACK_TARGETS

.PHONY: up-$(1) down-$(1) restart-$(1) pull-$(1) logs-$(1) ps-$(1)

up-$(1): networks-create ## Start $(1)
	@echo "  ▶ $(1)"
	@$$(call compose_cmd,$(1)) up -d --remove-orphans

down-$(1): ## Stop $(1)
	@echo "  ■ $(1)"
	@$$(call compose_cmd,$(1)) down

restart-$(1): down-$(1) up-$(1) ## Restart $(1)

pull-$(1): ## Pull latest images for $(1)
	@echo "  ↓ $(1)"
	@$$(call compose_cmd,$(1)) pull

logs-$(1): ## Tail logs for $(1) (pass ARGS= for extra flags)
	@$$(call compose_cmd,$(1)) logs -f --tail=100 $$(ARGS)

ps-$(1): ## Show status of $(1)
	@$$(call compose_cmd,$(1)) ps

endef

$(foreach stack,$(STACKS),$(eval $(call STACK_TARGETS,$(stack))))

# ─── Observability ────────────────────────────────────────────

.PHONY: ps logs

ps: ## Show status of all stacks
	@for stack in $(STACKS); do \
		echo "━━━ $$stack ━━━"; \
		$(call compose_cmd,$$stack) ps 2>/dev/null || echo "  (not running)"; \
		echo ""; \
	done

logs: ## Tail logs for all stacks (pass ARGS= for extra flags)
	@for stack in $(STACKS); do \
		echo "━━━ $$stack ━━━"; \
		$(call compose_cmd,$$stack) logs -f --tail=50 $(ARGS) & \
	done; \
	wait

# ─── Environment ──────────────────────────────────────────────

.PHONY: env env-check

env: ## Copy .env.example → .env for stacks that lack a .env
	@echo "━━━ Environment files ━━━"
	@for stack in $(STACKS); do \
		dir=$(DOCKER_DIR)/$$stack; \
		if [ -f "$$dir/.env.example" ] && [ ! -f "$$dir/.env" ]; then \
			cp "$$dir/.env.example" "$$dir/.env"; \
			echo "  + $$stack/.env (created from .env.example – edit before starting)"; \
		elif [ -f "$$dir/.env" ]; then \
			echo "  ✓ $$stack/.env (exists)"; \
		else \
			echo "  · $$stack/.env.example (not found, skipping)"; \
		fi; \
	done
	@echo ""

env-check: ## Verify every stack with an .env.example has a matching .env
	@echo "━━━ Environment check ━━━"
	@all_ok=true; \
	for stack in $(STACKS); do \
		dir=$(DOCKER_DIR)/$$stack; \
		if [ -f "$$dir/.env.example" ] && [ ! -f "$$dir/.env" ]; then \
			echo "  ✗ $$stack/.env is missing (run 'make env' then fill in values)"; \
			all_ok=false; \
		elif [ -f "$$dir/.env" ]; then \
			echo "  ✓ $$stack/.env"; \
		fi; \
	done; \
	$$all_ok || exit 1
	@echo ""

# ─── Cleanup ──────────────────────────────────────────────────

.PHONY: clean nuke

clean: down networks-remove ## Stop everything and remove external networks
	@echo "✔ Clean complete"

nuke: clean ## Clean + prune unused Docker resources (volumes, images, networks)
	@echo "━━━ Pruning unused Docker resources ━━━"
	docker system prune -af --volumes
	@echo ""
	@echo "✔ Nuke complete"

# ─── Help ─────────────────────────────────────────────────────

.PHONY: help

help: ## Show this help
	@echo ""
	@echo "  HeliumLab Docker Management"
	@echo "  ═══════════════════════════"
	@echo ""
	@echo "  Stacks (boot order): $(STACKS)"
	@echo "  Networks:            $(NETWORKS)"
	@echo ""
	@echo "  Usage: make <target>"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"} \
		/^[a-zA-Z_0-9-]+:.*##/ { \
			printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2 \
		}' $(MAKEFILE_LIST)
	@echo ""
	@echo "  Tip: pass extra args to log targets with ARGS="
	@echo "       e.g.  make logs-reverse-proxy ARGS='traefik'"
	@echo ""
