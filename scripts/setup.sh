#!/bin/bash

# Liquibase PostgreSQL Project Setup Script
# This script sets up the initial environment for the project

set -e

echo "🚀 Setting up Liquibase PostgreSQL Project..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

print_status "Docker and Docker Compose are installed."

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    print_status "Creating .env file from template..."
    if [ -f env.example ]; then
        cp env.example .env
        print_status ".env file created successfully."
    else
        print_warning "env.example not found. Creating basic .env file..."
        cat > .env << EOF
# PostgreSQL Configuration
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_ADMIN_USER=postgres
POSTGRES_ADMIN_PASSWORD=admin123
POSTGRES_DB=api
POSTGRES_APP_USER=api_user
POSTGRES_APP_PASSWORD=api_password

# Liquibase Configuration
LIQUIBASE_VERSION=4.25.0

# Database Connection URLs
POSTGRES_URL=jdbc:postgresql://\${POSTGRES_HOST}:\${POSTGRES_PORT}/\${POSTGRES_DB}
POSTGRES_ADMIN_URL=jdbc:postgresql://\${POSTGRES_HOST}:\${POSTGRES_PORT}/postgres
EOF
        print_status "Basic .env file created."
    fi
else
    print_status ".env file already exists."
fi

# Create necessary directories
print_status "Creating necessary directories..."
mkdir -p liquibase/lib
mkdir -p liquibase/changelog/sql

# Download PostgreSQL JDBC driver if not exists
if [ ! -f liquibase/lib/postgresql-42.6.0.jar ]; then
    print_status "Downloading PostgreSQL JDBC driver..."
    curl -L -o liquibase/lib/postgresql-42.6.0.jar \
        https://jdbc.postgresql.org/download/postgresql-42.6.0.jar
    print_status "PostgreSQL JDBC driver downloaded."
else
    print_status "PostgreSQL JDBC driver already exists."
fi

# Make scripts executable
chmod +x scripts/*.sh

print_status "Setup completed successfully! 🎉"
echo ""
print_status "Next steps:"
echo "  1. Edit .env file if needed"
echo "  2. Run: ./scripts/run-liquibase.sh"
echo "  3. Or run: docker-compose up -d"
echo ""
print_status "Happy coding! 🚀" 