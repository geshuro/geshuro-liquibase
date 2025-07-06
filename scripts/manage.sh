#!/bin/bash

# Liquibase PostgreSQL Project Management Script
# This script provides comprehensive project management functions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}[MANAGE]${NC} $1"
}

print_section() {
    echo -e "${PURPLE}[SECTION]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Liquibase PostgreSQL Project Manager"
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  start           Start PostgreSQL and apply Liquibase changes"
    echo "  stop            Stop all containers"
    echo "  restart         Restart all containers"
    echo "  status          Show status of containers and database"
    echo "  logs            Show logs from containers"
    echo "  clean           Stop containers and remove volumes"
    echo "  reset           Clean and start fresh"
    echo "  backup          Create database backup"
    echo "  restore         Restore database from backup"
    echo "  shell           Open shell in PostgreSQL container"
    echo "  psql            Connect to PostgreSQL with psql"
    echo "  help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start"
    echo "  $0 status"
    echo "  $0 logs"
    echo "  $0 psql"
    echo ""
}

# Function to check if .env exists
check_env() {
    if [ ! -f .env ]; then
        print_error ".env file not found. Please run setup first: ./scripts/setup.sh"
        exit 1
    fi
}

# Function to load environment variables
load_env() {
    if [ -f .env ]; then
        export $(cat .env | grep -v '^#' | xargs)
    fi
}

# Function to start the project
start_project() {
    print_section "Starting Liquibase PostgreSQL Project"
    check_env
    load_env
    
    print_status "Starting PostgreSQL container..."
    docker-compose up -d postgres
    
    print_status "Waiting for PostgreSQL to be ready..."
    sleep 15
    
    print_status "Running Liquibase update..."
    ./scripts/run-liquibase.sh update
    
    print_status "Project started successfully! 🎉"
    print_status "PostgreSQL is running on localhost:${POSTGRES_PORT:-5432}"
    print_status "Database: ${POSTGRES_DB:-myapp}"
    print_status "User: ${POSTGRES_APP_USER:-appuser}"
}

# Function to stop the project
stop_project() {
    print_section "Stopping Liquibase PostgreSQL Project"
    print_status "Stopping containers..."
    docker-compose down
    print_status "Project stopped successfully!"
}

# Function to restart the project
restart_project() {
    print_section "Restarting Liquibase PostgreSQL Project"
    stop_project
    sleep 2
    start_project
}

# Function to show status
show_status() {
    print_section "Project Status"
    
    echo ""
    print_header "Container Status:"
    docker-compose ps
    
    echo ""
    print_header "Database Status:"
    if docker ps | grep -q liquibase-postgres; then
        if docker-compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1; then
            print_status "PostgreSQL is running and healthy"
            
            # Show database info
            echo ""
            print_header "Database Information:"
            docker-compose exec -T postgres psql -U postgres -d myapp -c "
                SELECT 
                    'Database: ' || current_database() as info
                UNION ALL
                SELECT 'User: ' || current_user
                UNION ALL
                SELECT 'Tables: ' || count(*)::text FROM information_schema.tables WHERE table_schema = 'public'
                UNION ALL
                SELECT 'Users: ' || count(*)::text FROM users
                UNION ALL
                SELECT 'Products: ' || count(*)::text FROM products
                UNION ALL
                SELECT 'Categories: ' || count(*)::text FROM categories;
            " 2>/dev/null || print_warning "Could not connect to database"
        else
            print_warning "PostgreSQL is running but not ready"
        fi
    else
        print_warning "PostgreSQL container is not running"
    fi
    
    echo ""
    print_header "Liquibase Status:"
    ./scripts/run-liquibase.sh status 2>/dev/null || print_warning "Could not check Liquibase status"
}

# Function to show logs
show_logs() {
    print_section "Container Logs"
    docker-compose logs --tail=50 "$1"
}

# Function to clean up
clean_project() {
    print_section "Cleaning Project"
    print_warning "This will stop containers and remove volumes. All data will be lost!"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Stopping containers and removing volumes..."
        docker-compose down -v
        print_status "Clean completed!"
    else
        print_status "Clean cancelled."
    fi
}

# Function to reset project
reset_project() {
    print_section "Resetting Project"
    print_warning "This will clean everything and start fresh!"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        clean_project
        sleep 2
        start_project
    else
        print_status "Reset cancelled."
    fi
}

# Function to backup database
backup_database() {
    local backup_file="backup_$(date +%Y%m%d_%H%M%S).sql"
    print_section "Creating Database Backup"
    print_status "Backup file: $backup_file"
    
    docker-compose exec -T postgres pg_dump -U postgres -d myapp > "$backup_file"
    print_status "Backup created successfully!"
}

# Function to restore database
restore_database() {
    local backup_file="$1"
    if [ -z "$backup_file" ]; then
        print_error "Please specify a backup file to restore from."
        echo "Example: $0 restore backup_20231201_120000.sql"
        exit 1
    fi
    
    if [ ! -f "$backup_file" ]; then
        print_error "Backup file not found: $backup_file"
        exit 1
    fi
    
    print_section "Restoring Database from Backup"
    print_warning "This will overwrite the current database!"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Restoring from: $backup_file"
        docker-compose exec -T postgres psql -U postgres -d myapp < "$backup_file"
        print_status "Restore completed successfully!"
    else
        print_status "Restore cancelled."
    fi
}

# Function to open shell
open_shell() {
    print_section "Opening Shell in PostgreSQL Container"
    docker-compose exec postgres bash
}

# Function to connect with psql
connect_psql() {
    print_section "Connecting to PostgreSQL with psql"
    docker-compose exec postgres psql -U postgres -d myapp
}

# Main script logic
case "${1:-help}" in
    "start")
        start_project
        ;;
    
    "stop")
        stop_project
        ;;
    
    "restart")
        restart_project
        ;;
    
    "status")
        show_status
        ;;
    
    "logs")
        show_logs "$2"
        ;;
    
    "clean")
        clean_project
        ;;
    
    "reset")
        reset_project
        ;;
    
    "backup")
        backup_database
        ;;
    
    "restore")
        restore_database "$2"
        ;;
    
    "shell")
        open_shell
        ;;
    
    "psql")
        connect_psql
        ;;
    
    "help"|"-h"|"--help")
        show_usage
        ;;
    
    *)
        print_error "Unknown command: $1"
        echo ""
        show_usage
        exit 1
        ;;
esac 