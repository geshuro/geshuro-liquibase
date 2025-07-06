-- Initial SQL script for PostgreSQL container
-- This script runs when the PostgreSQL container starts for the first time

-- Create the application database if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'myapp') THEN
        CREATE DATABASE myapp;
    END IF;
END
$$;

-- Connect to the myapp database
\c myapp;

-- Create the application user if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_user WHERE usename = 'appuser') THEN
        CREATE USER appuser WITH PASSWORD 'app123';
    END IF;
END
$$;

-- Grant necessary privileges to the application user
GRANT CONNECT ON DATABASE myapp TO appuser;
GRANT USAGE ON SCHEMA public TO appuser;
GRANT CREATE ON SCHEMA public TO appuser;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO appuser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO appuser;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO appuser;

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO appuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO appuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO appuser;

-- Create a function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Log completion
DO $$
BEGIN
    RAISE NOTICE 'Initial SQL script completed successfully';
    RAISE NOTICE 'Database: myapp';
    RAISE NOTICE 'User: appuser';
    RAISE NOTICE 'Ready for Liquibase to apply changes';
END
$$; 