# Liquibase PostgreSQL Project

Este proyecto utiliza Liquibase para gestionar una base de datos PostgreSQL, incluyendo la creación de usuarios, bases de datos, tablas y datos iniciales usando archivos YAML.

## Cambios recientes importantes

- **La base de datos por defecto es `myapp`** (no `postgres`).
- **Liquibase debe ejecutarse con el usuario `postgres`** para tener permisos de crear tablas y esquemas.
- **Los scripts de inicialización SQL no deben crear la base de datos**; el contenedor la crea automáticamente.
- **Las rutas de los changelogs en el master deben ser relativas a `changelog/`**.
- **Para reiniciar y aplicar cambios:**
  1. `docker-compose down`
  2. `docker-compose up -d`
  3. `make update`

## Estructura del Proyecto

```
liquibase-run/
├── liquibase/
│   ├── changelog/
│   │   ├── db-changelog-master.yaml
│   │   ├── changes/
│   │   │   ├── 001-create-database.yaml
│   │   │   ├── 002-create-user.yaml
│   │   │   ├── 003-create-tables.yaml
│   │   │   └── 004-insert-initial-data.yaml
│   │   └── sql/
│   │       ├── 001-create-database.sql
│   │       └── 002-init-myapp.sql
│   ├── liquibase.properties
│   └── lib/
├── docker-compose.yml
├── env.example
├── Makefile
├── scripts/
│   ├── setup.sh
│   ├── run-liquibase.sh
│   └── manage.sh
└── README.md
```

## Prerrequisitos

- Docker y Docker Compose
- Java 8 o superior
- Liquibase CLI (opcional, se incluye en Docker)
- Make (para usar el Makefile)

## Configuración Rápida

### Usando Makefile (Recomendado)

1. **Configurar el proyecto:**
   ```bash
   make setup
   ```

2. **Iniciar el proyecto completo:**
   ```bash
   make start
   ```

3. **Verificar el estado:**
   ```bash
   make status
   ```

### Reinicio y aplicación de cambios

Si cambiaste la base de datos, usuarios o los scripts de inicialización:

```bash
docker-compose down
docker-compose up -d
make update
```

## Ejemplo de conexión con appuser

Para probar la conexión con el usuario de aplicación:

```bash
docker exec -it liquibase-postgres psql -U appuser -d myapp -c "SELECT current_user, current_database();"
```

## Solución de problemas

- **Las tablas o datos aparecen en la base de datos `postgres` y no en `myapp`:**
  - Asegúrate de que en `docker-compose.yml` esté:
    ```yaml
    POSTGRES_DB: myapp
    ```
  - Elimina cualquier línea `CREATE DATABASE myapp;` de los scripts SQL.
  - Reinicia el contenedor y aplica los cambios de nuevo.

- **Liquibase da error de permisos al crear tablas:**
  - Usa el usuario `postgres` en `liquibase/liquibase.properties`:
    ```
    username: postgres
    password: admin123
    ```

- **Liquibase no encuentra los archivos de cambios:**
  - Asegúrate de que las rutas en `db-changelog-master.yaml` sean relativas a `changelog/`, por ejemplo:
    ```yaml
    - include:
        file: changelog/changes/003-create-tables.yaml
    ```

- **Para limpiar todo y empezar de cero:**
  ```bash
  make reset
  ```

## Variables de Entorno

Edita el archivo `.env` con tus configuraciones:

```bash
# PostgreSQL Configuration
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_ADMIN_USER=postgres
POSTGRES_ADMIN_PASSWORD=admin123
POSTGRES_DB=myapp
POSTGRES_APP_USER=appuser
POSTGRES_APP_PASSWORD=app123

# Liquibase Configuration
LIQUIBASE_VERSION=4.25.0
```

## Más información

Consulta el resto del README para detalles sobre los scripts, Makefile y estructura del proyecto.

## Configuración Manual

### Variables de Entorno

Edita el archivo `.env` con tus configuraciones:

```bash
# PostgreSQL Configuration
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_ADMIN_USER=postgres
POSTGRES_ADMIN_PASSWORD=admin123
POSTGRES_DB=myapp
POSTGRES_APP_USER=appuser
POSTGRES_APP_PASSWORD=app123

# Liquibase Configuration
LIQUIBASE_VERSION=4.25.0
```

### Ejecutar Liquibase Manualmente

```bash
# Usando Docker
docker run --rm -v $(pwd)/liquibase:/liquibase \
  --network host \
  liquibase/liquibase:4.25.0 \
  --defaultsFile=/liquibase/liquibase.properties \
  update

# Usando Liquibase CLI local
liquibase --defaultsFile=liquibase/liquibase.properties update
```

## Changelog

El proyecto incluye los siguientes cambios:

1. **001-create-database.yaml**: Creación de la base de datos
2. **002-create-user.yaml**: Creación del usuario de aplicación
3. **003-create-tables.yaml**: Creación de tablas principales
4. **004-insert-initial-data.yaml**: Inserción de datos iniciales

## Estructura de la Base de Datos

El proyecto crea las siguientes tablas:

- `users`: Tabla de usuarios del sistema
- `products`: Tabla de productos
- `categories`: Tabla de categorías
- `orders`: Tabla de órdenes
- `order_items`: Tabla de items de órdenes

## Comandos Útiles

### Gestión del Proyecto (Makefile)
```bash
# Iniciar todo el proyecto
make start

# Ver estado completo
make status

# Conectar a la base de datos
make psql

# Crear backup
make backup

# Ver logs
make logs

# Información del proyecto
make info
```

### Gestión del Proyecto (Scripts)
```bash
# Iniciar todo el proyecto
./scripts/manage.sh start

# Ver estado completo
./scripts/manage.sh status

# Conectar a la base de datos
./scripts/manage.sh psql

# Crear backup
./scripts/manage.sh backup

# Ver logs
./scripts/manage.sh logs
```

### Liquibase Específicos
```bash
# Verificar estado de la base de datos
make status-liquibase

# Generar SQL sin ejecutar
make update-sql

# Rollback a una versión específica
make rollback VERSION=1.0.0

# Generar documentación
make docs
```

## Troubleshooting

### Problemas Comunes

1. **Error de conexión**: Verificar que PostgreSQL esté ejecutándose
   ```bash
   make status
   ```

2. **Error de permisos**: Verificar credenciales en `.env`
   ```bash
   cat .env
   ```

3. **Error de Liquibase**: Verificar versión de Java y Liquibase
   ```bash
   make validate
   ```

### Logs

```bash
# Ver logs de PostgreSQL
make logs postgres

# Ver logs de Liquibase
make logs liquibase
```

### Reset Completo

Si necesitas empezar de nuevo:
```bash
make reset
```

## Contribución

1. Crear un nuevo archivo de cambio en `liquibase/changelog/changes/`
2. Agregar la referencia al changelog master
3. Probar los cambios localmente
4. Commit y push

## Licencia

MIT License 