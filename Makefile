# Liquibase PostgreSQL Project Makefile
# This Makefile provides easy access to all project commands

.PHONY: help setup start stop restart status logs clean reset backup restore shell psql update rollback validate docs

# Default target
help: ## Show this help message
	@echo "Liquibase PostgreSQL Project - Available Commands:"
	@echo ""
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "Examples:"
	@echo "  make setup    # Initial project setup"
	@echo "  make start    # Start PostgreSQL and apply changes"
	@echo "  make status   # Show project status"
	@echo "  make psql     # Connect to database"

# Project Management
setup: ## Initial project setup
	@echo "🚀 Setting up Liquibase PostgreSQL Project..."
	@./scripts/setup.sh

start: ## Start PostgreSQL and apply Liquibase changes
	@echo "▶️  Starting Liquibase PostgreSQL Project..."
	@./scripts/manage.sh start

stop: ## Stop all containers
	@echo "⏹️  Stopping project..."
	@./scripts/manage.sh stop

restart: ## Restart all containers
	@echo "🔄 Restarting project..."
	@./scripts/manage.sh restart

status: ## Show status of containers and database
	@echo "📊 Project Status:"
	@./scripts/manage.sh status

logs: ## Show container logs
	@echo "📋 Container Logs:"
	@./scripts/manage.sh logs

clean: ## Stop containers and remove volumes
	@echo "🧹 Cleaning project..."
	@./scripts/manage.sh clean

reset: ## Clean and start fresh
	@echo "🔄 Resetting project..."
	@./scripts/manage.sh reset

# Database Operations
backup: ## Create database backup
	@echo "💾 Creating database backup..."
	@./scripts/manage.sh backup

restore: ## Restore database from backup (usage: make restore BACKUP_FILE=backup.sql)
	@echo "📥 Restoring database from backup..."
	@./scripts/manage.sh restore $(BACKUP_FILE)

shell: ## Open shell in PostgreSQL container
	@echo "🐚 Opening shell in PostgreSQL container..."
	@./scripts/manage.sh shell

psql: ## Connect to PostgreSQL with psql
	@echo "🗄️  Connecting to PostgreSQL..."
	@./scripts/manage.sh psql

# Liquibase Commands
update: ## Apply all pending Liquibase changesets
	@echo "🔄 Applying Liquibase changes..."
	@./scripts/run-liquibase.sh update

rollback: ## Rollback to specific version (usage: make rollback VERSION=1.0.0)
	@echo "⏪ Rolling back to version $(VERSION)..."
	@./scripts/run-liquibase.sh rollback $(VERSION)

validate: ## Validate Liquibase changelog
	@echo "✅ Validating changelog..."
	@./scripts/run-liquibase.sh validate

status-liquibase: ## Show Liquibase status
	@echo "📊 Liquibase Status:"
	@./scripts/run-liquibase.sh status

update-sql: ## Generate SQL without executing
	@echo "📝 Generating SQL..."
	@./scripts/run-liquibase.sh updateSQL

docs: ## Generate database documentation
	@echo "📚 Generating documentation..."
	@./scripts/run-liquibase.sh dbDoc

# Development Commands
dev-start: ## Start in development mode (with logs)
	@echo "🔧 Starting in development mode..."
	@docker-compose up

dev-stop: ## Stop development mode
	@echo "⏹️  Stopping development mode..."
	@docker-compose down

dev-logs: ## Show development logs
	@echo "📋 Development logs:"
	@docker-compose logs -f

# Utility Commands
check-env: ## Check if .env file exists
	@if [ ! -f .env ]; then \
		echo "❌ .env file not found. Run 'make setup' first."; \
		exit 1; \
	else \
		echo "✅ .env file found."; \
	fi

check-docker: ## Check if Docker is running
	@if ! docker info > /dev/null 2>&1; then \
		echo "❌ Docker is not running. Please start Docker first."; \
		exit 1; \
	else \
		echo "✅ Docker is running."; \
	fi

info: ## Show project information
	@echo "📋 Project Information:"
	@echo "  Project: Liquibase PostgreSQL"
	@echo "  Database: myapp"
	@echo "  User: appuser"
	@echo "  Port: 5432"
	@echo ""
	@echo "📁 Project Structure:"
	@echo "  liquibase/          - Liquibase configuration and changelogs"
	@echo "  scripts/            - Management scripts"
	@echo "  docker-compose.yml  - Docker services configuration"
	@echo "  .env               - Environment variables"

# Quick Commands
quick-start: check-env check-docker ## Quick start (setup + start)
	@make setup
	@make start

quick-reset: check-env check-docker ## Quick reset (clean + start)
	@make clean
	@make start

# Database Connection Info
db-info: ## Show database connection information
	@echo "🗄️  Database Connection Information:"
	@echo "  Host: localhost"
	@echo "  Port: 5432"
	@echo "  Database: myapp"
	@echo "  User: appuser"
	@echo "  Password: app123"
	@echo ""
	@echo "🔗 Connection URL:"
	@echo "  jdbc:postgresql://localhost:5432/myapp"
	@echo ""
	@echo "📝 psql command:"
	@echo "  psql -h localhost -p 5432 -U appuser -d myapp"

# Maintenance Commands
maintenance: ## Show maintenance commands
	@echo "🔧 Maintenance Commands:"
	@echo "  make backup          - Create database backup"
	@echo "  make restore         - Restore from backup"
	@echo "  make clean           - Clean containers and volumes"
	@echo "  make reset           - Reset everything"
	@echo "  make validate        - Validate changelog"
	@echo "  make docs            - Generate documentation"

# Shortcuts
s: setup ## Alias for setup
u: update ## Alias for update
st: status ## Alias for status
l: logs ## Alias for logs
p: psql ## Alias for psql 