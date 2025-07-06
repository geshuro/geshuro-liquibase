#!/bin/bash

# Liquibase PostgreSQL Project Runner Script
# This script runs Liquibase commands to manage the database

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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
    echo -e "${BLUE}[LIQUIBASE]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  update          Apply all pending changesets"
    echo "  status          Show the status of changesets"
    echo "  rollback        Rollback to a specific version"
    echo "  updateSQL       Generate SQL without executing"
    echo "  dbDoc           Generate database documentation"
    echo "  validate        Validate the changelog"
    echo "  help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 update"
    echo "  $0 status"
    echo "  $0 rollback 1.0.0"
    echo "  $0 updateSQL"
    echo ""
}

# Function to check if PostgreSQL is running
check_postgres() {
    if ! docker ps | grep -q liquibase-postgres; then
        print_warning "PostgreSQL container is not running. Starting it..."
        docker-compose up -d postgres
        
        # Wait for PostgreSQL to be ready
        print_status "Waiting for PostgreSQL to be ready..."
        sleep 30
        
        # Check if PostgreSQL is healthy
        local max_attempts=10
        local attempt=1
        
        while [ $attempt -le $max_attempts ]; do
            if docker-compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1; then
                print_status "PostgreSQL is ready!"
                break
            else
                print_warning "PostgreSQL is not ready yet (attempt $attempt/$max_attempts)..."
                sleep 5
                attempt=$((attempt + 1))
            fi
        done
        
        if [ $attempt -gt $max_attempts ]; then
            print_error "PostgreSQL is not ready after $max_attempts attempts. Please check the logs: docker-compose logs postgres"
            exit 1
        fi
    fi
}

# Function to run Liquibase command
run_liquibase() {
    local command="$1"
    local args="$2"
    
    print_header "Running: liquibase $command $args"
    
    docker run --rm \
        -v "$(pwd)/liquibase/changelog:/liquibase/changelog" \
        -v "$(pwd)/liquibase/liquibase.properties:/liquibase/liquibase.properties" \
        -v "$(pwd)/liquibase/lib:/liquibase/lib" \
        --network host \
        liquibase/liquibase:4.24.0 \
        --defaultsFile=/liquibase/liquibase.properties \
        "$command" $args
}

# Main script logic
case "${1:-update}" in
    "update")
        print_status "Starting Liquibase update..."
        check_postgres
        run_liquibase "update"
        print_status "Update completed successfully! 🎉"
        ;;
    
    "status")
        print_status "Checking Liquibase status..."
        check_postgres
        run_liquibase "status"
        ;;
    
    "rollback")
        if [ -z "$2" ]; then
            print_error "Please specify a version to rollback to."
            echo "Example: $0 rollback 1.0.0"
            exit 1
        fi
        print_status "Rolling back to version: $2"
        check_postgres
        run_liquibase "rollback" "$2"
        print_status "Rollback completed successfully!"
        ;;
    
    "updateSQL")
        print_status "Generating SQL without executing..."
        check_postgres
        run_liquibase "updateSQL"
        print_status "SQL generated successfully!"
        ;;
    
    "dbDoc")
        print_status "Generating database documentation..."
        check_postgres
        mkdir -p docs
        run_liquibase "dbDoc" "docs/"
        print_status "Documentation generated in docs/ directory!"
        ;;
    
    "validate")
        print_status "Validating changelog..."
        check_postgres
        run_liquibase "validate"
        print_status "Changelog validation completed!"
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