# ============================================
# Radio Andrews - Makefile
# ============================================

.PHONY: help install dev up down restart logs logs-icecast logs-liquidsoap \
        status shell-liquidsoap clean clean-all \
        lint lint-fix test serve

# Colors
YELLOW := \033[1;33m
GREEN := \033[1;32m
CYAN := \033[1;36m
RESET := \033[0m

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
	uv sync

install-dev: ## Install dev dependencies
	uv sync --group dev

# ============================================
# DOCKER - MAIN COMMANDS
# ============================================

up: ## Start all services (background)
	docker compose up -d
	@echo ""
	@echo "$(GREEN)Done! Services are running.$(RESET)"
	@echo "  Stream:  http://localhost:8000/stream"
	@echo "  Status:  http://localhost:8000"
	@echo ""

down: ## Stop all services
	docker compose down

restart: ## Restart all services
	docker compose restart

dev: ## Start with logs (for development)
	docker compose up

# ============================================
# LOGS
# ============================================

logs: ## Show logs (all services)
	docker compose logs -f --tail=100

logs-icecast: ## Show Icecast logs only
	docker compose logs -f --tail=100 icecast

logs-liquidsoap: ## Show Liquidsoap logs only
	docker compose logs -f --tail=100 liquidsoap

# ============================================
# STATUS AND DEBUG
# ============================================

status: ## Show container status
	@echo ""
	@echo "$(CYAN)Containers:$(RESET)"
	@docker compose ps
	@echo ""
	@echo "$(CYAN)Listeners:$(RESET)"
	@curl -s http://localhost:8000/status-json.xsl 2>/dev/null | \
		python3 -c "import sys,json; d=json.load(sys.stdin); \
		print(f\"  Connected: {d.get('icestats',{}).get('source',{}).get('listeners',0)}\")" \
		2>/dev/null || echo "  Icecast not available"
	@echo ""

shell-liquidsoap: ## Open shell in Liquidsoap container
	docker compose exec liquidsoap sh

# ============================================
# PYTHON DEVELOPMENT
# ============================================

lint: ## Run linter
	uv run ruff check src/ tests/

lint-fix: ## Fix linter errors
	uv run ruff check --fix src/ tests/
	uv run ruff format src/ tests/

format: ## Format code
	uv run ruff format src/ tests/

test: ## Run tests
	uv run pytest -v

test-cov: ## Run tests with coverage
	uv run pytest --cov=src --cov-report=html

# ============================================
# LOCAL SERVER
# ============================================

serve: ## Start local server for static files (port 8080)
	@echo "$(GREEN)Open http://localhost:8080$(RESET)"
	cd static && python3 -m http.server 8080

# ============================================
# API DEVELOPMENT
# ============================================

api-dev: ## Run Flask API locally (development mode)
	FLASK_ENV=development CURRENT_TRACK_FILE=data/current_track.json \
		$(UV) run flask --app radio_andrews.app:create_app run --debug --port 5000

api-logs: ## Show API logs
	docker compose logs -f --tail=100 api

shell-api: ## Open shell in API container
	docker compose exec api sh

# ============================================
# DATABASE
# ============================================

db-init: ## Initialize database
	docker compose exec api uv run flask --app radio_andrews.app:create_app init-db

db-scan: ## Scan music folder and add tracks to database
	docker compose exec api uv run flask --app radio_andrews.app:create_app scan-music

db-tracks: ## List all tracks in database
	docker compose exec api uv run flask --app radio_andrews.app:create_app list-tracks

# ============================================
# CLEANUP
# ============================================

clean: ## Remove Python cache files
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".ruff_cache" -exec rm -rf {} + 2>/dev/null || true

clean-docker: ## Remove Docker volumes and containers
	docker compose down -v --remove-orphans

clean-all: clean clean-docker ## Full cleanup

# ============================================
# MUSIC
# ============================================

music-list: ## Show playlist
	@echo ""
	@echo "$(CYAN)Tracks in playlist:$(RESET)"
	@ls -1 music/*.mp3 2>/dev/null || echo "  No MP3 files"
	@echo ""
	@echo "Total: $$(ls -1 music/*.mp3 2>/dev/null | wc -l | tr -d ' ') tracks"
	@echo ""

music-reload: ## Reload playlist (restart Liquidsoap)
	docker compose restart liquidsoap

# ============================================
# GIT
# ============================================

commit-check: lint test ## Run checks before commit
	@echo "$(GREEN)All checks passed!$(RESET)"
