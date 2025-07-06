-- Script para crear usuario y privilegios en la base de datos myapp
-- Este script se ejecuta conectado a la base de datos myapp (creada automáticamente por el contenedor)

DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_user WHERE usename = 'appuser') THEN
        CREATE USER appuser WITH PASSWORD 'app123';
    END IF;
END
$$;

GRANT CONNECT ON DATABASE myapp TO appuser;
GRANT USAGE ON SCHEMA public TO appuser;
GRANT CREATE ON SCHEMA public TO appuser;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO appuser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO appuser;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO appuser;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO appuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO appuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO appuser; 