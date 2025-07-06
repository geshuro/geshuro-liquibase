#!/bin/bash

# Liquibase Initial Setup Script
# This script runs Liquibase as superuser to create database and user

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker container is running
if ! docker ps | grep -q "liquibase-postgres"; then
    print_error "PostgreSQL container is not running. Please start it first with 'make start'"
    exit 1
fi

# Wait for PostgreSQL to be ready
print_info "Waiting for PostgreSQL to be ready..."
until docker exec liquibase-postgres pg_isready -U postgres > /dev/null 2>&1; do
    sleep 1
done
print_success "PostgreSQL is ready!"

# Run Liquibase with initial configuration
print_info "Running Liquibase initial setup (as superuser)..."
print_info "This will create the database and user..."

cd "$(dirname "$0")/.."

# Run Liquibase with the initial properties file
docker run --rm \
    --network liquibase-run_liquibase-network \
    -v "$(pwd)/liquibase/liquibase-init.properties:/liquibase/liquibase.properties" \
    -v "$(pwd)/liquibase/changelog:/liquibase/changelog" \
    -v "$(pwd)/liquibase/lib:/liquibase/lib" \
    -w /liquibase/changelog \
    liquibase/liquibase:4.24.0 \
    --defaultsFile=/liquibase/liquibase.properties \
    update

print_success "Liquibase initial setup completed!"
print_info "Now you can run the regular Liquibase update with './scripts/run-liquibase.sh'" 