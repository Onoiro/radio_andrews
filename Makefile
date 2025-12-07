# ============================================
# Radio Andrews - Makefile
# ============================================

.PHONY: help install dev up down restart logs logs-icecast logs-liquidsoap \
        status shell-liquidsoap clean clean-all \
        lint lint-fix test serve \
        deploy deploy-down deploy-restart deploy-logs deploy-status \
        deploy-scan deploy-tracks

# Colors
YELLOW := \033[1;33m
GREEN := \033[1;32m
CYAN := \033[1;36m
RESET := \033[0m

# Find uv in common locations
UV := $(shell command -v uv 2>/dev/null || echo "$(HOME)/.local/bin/uv")

# ============================================
# HELP
# ============================================

help: ## Show this help
	@echo ""
	@echo "$(CYAN)Radio Andrews - Development Commands$(RESET)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-18s$(RESET) %s\n", $$1, $$2}'
	@echo ""

# ============================================
# INSTALL
# ============================================

install: ## Install Python dependencies
	$(UV) sync

install-dev: ## Install dev dependencies
	$(UV) sync --group dev

# ============================================
# DOCKER - LOCAL DEVELOPMENT
# ============================================

up: ## Start local services (background)
	docker compose up -d
	@echo ""
	@echo "$(GREEN)Done! Services are running.$(RESET)"
	@echo "  Stream:  http://localhost:8000/stream"
	@echo "  API:     http://localhost:5000"
	@echo ""

down: ## Stop local services
	docker compose down

restart: ## Restart local services
	docker compose restart

dev: ## Start local with logs
	docker compose up

# ============================================
# DOCKER - PRODUCTION (run on server)
# ============================================

deploy: ## Build and start production services
	docker compose -f docker-compose.prod.yml build
	docker compose -f docker-compose.prod.yml up -d
	@echo ""
	@echo "$(GREEN)Production services started!$(RESET)"
	@echo ""

deploy-down: ## Stop production services
	docker compose -f docker-compose.prod.yml down

deploy-restart: ## Restart production services
	docker compose -f docker-compose.prod.yml restart

deploy-logs: ## Show production logs
	docker compose -f docker-compose.prod.yml logs -f --tail=100

deploy-status: ## Show production status
	docker compose -f docker-compose.prod.yml ps

# ============================================
# DATABASE - LOCAL
# ============================================

db-init: ## Initialize local database
	docker compose exec api uv run flask --app radio_andrews.app:create_app init-db

db-scan: ## Scan local music folder
	docker compose exec api uv run flask --app radio_andrews.app:create_app scan-music

db-tracks: ## List local tracks
	docker compose exec api uv run flask --app radio_andrews.app:create_app list-tracks

# ============================================
# DATABASE - PRODUCTION (run on server)
# ============================================

deploy-scan: ## Scan production music folder
	docker compose -f docker-compose.prod.yml exec api uv run flask --app radio_andrews.app:create_app scan-music

deploy-tracks: ## List production tracks
	docker compose -f docker-compose.prod.yml exec api uv run flask --app radio_andrews.app:create_app list-tracks

# ============================================
# LOGS - LOCAL
# ============================================

logs: ## Show local logs (all services)
	docker compose logs -f --tail=100

logs-icecast: ## Show Icecast logs only
	docker compose logs -f --tail=100 icecast

logs-liquidsoap: ## Show Liquidsoap logs only
	docker compose logs -f --tail=100 liquidsoap

# ============================================
# STATUS AND DEBUG
# ============================================

status: ## Show local container status
	@echo ""
	@echo "$(CYAN)Containers:$(RESET)"
	@docker compose ps
	@echo ""

shell-liquidsoap: ## Open shell in Liquidsoap container
	docker compose exec liquidsoap sh

shell-api: ## Open shell in API container
	docker compose exec api sh

# ============================================
# PYTHON DEVELOPMENT
# ============================================

lint: ## Run linter
	$(UV) run ruff check src/ tests/

lint-fix: ## Fix linter errors
	$(UV) run ruff check --fix src/ tests/
	$(UV) run ruff format src/ tests/

format: ## Format code
	$(UV) run ruff format src/ tests/

test: ## Run tests
	$(UV) run pytest -v

test-cov: ## Run tests with coverage
	$(UV) run pytest --cov=src --cov-report=term-missing:skip-covered --cov-report=html

# ============================================
# LOCAL SERVER
# ============================================

serve: ## Start local server for static files (port 8080)
	@echo "$(GREEN)Open http://localhost:8080$(RESET)"
	cd static && python3 -m http.server 8080

# ============================================
# MUSIC
# ============================================

music-list: ## Show local playlist
	@echo ""
	@echo "$(CYAN)Tracks in playlist:$(RESET)"
	@ls -1 music/*.mp3 2>/dev/null || echo "  No MP3 files"
	@echo ""
	@echo "Total: $$(ls -1 music/*.mp3 2>/dev/null | wc -l | tr -d ' ') tracks"
	@echo ""

music-reload: ## Reload playlist (restart Liquidsoap)
	docker compose restart liquidsoap

deploy-music-reload: ## Reload production playlist
	docker compose -f docker-compose.prod.yml restart liquidsoap

# ============================================
# CLEANUP
# ============================================

clean: ## Remove Python cache files
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".ruff_cache" -exec rm -rf {} + 2>/dev/null || true

clean-docker: ## Remove local Docker volumes
	docker compose down -v --remove-orphans

clean-all: clean clean-docker ## Full cleanup

# ============================================
# GIT
# ============================================

commit-check: lint test ## Run checks before commit
	@echo "$(GREEN)All checks passed!$(RESET)"
