# Guía de Uso - Liquibase PostgreSQL Project

Esta guía muestra ejemplos prácticos de cómo usar el proyecto con el Makefile.

## 🚀 Inicio Rápido

### Primer Uso
```bash
# 1. Configurar el proyecto
make setup

# 2. Iniciar todo
make start

# 3. Verificar que todo funciona
make status
```

### Uso Diario
```bash
# Iniciar el proyecto
make start

# Ver estado
make status

# Conectar a la base de datos
make psql

# Detener el proyecto
make stop
```

## 📋 Comandos por Categoría

### Configuración Inicial
```bash
make setup          # Configuración inicial completa
make quick-start    # Setup + start en un comando
make info           # Información del proyecto
make db-info        # Información de conexión
```

### Gestión del Proyecto
```bash
make start          # Iniciar PostgreSQL y aplicar cambios
make stop           # Detener contenedores
make restart        # Reiniciar todo
make status         # Ver estado completo
make logs           # Ver logs de contenedores
```

### Base de Datos
```bash
make psql           # Conectar con psql
make shell          # Abrir shell en contenedor
make backup         # Crear backup
make restore        # Restaurar backup
```

### Liquibase
```bash
make update         # Aplicar cambios pendientes
make status-liquibase # Ver estado de Liquibase
make validate       # Validar changelog
make rollback       # Rollback a versión específica
make update-sql     # Generar SQL sin ejecutar
make docs           # Generar documentación
```

### Mantenimiento
```bash
make clean          # Limpiar contenedores y volúmenes
make reset          # Reset completo
make maintenance    # Ver comandos de mantenimiento
```

### Desarrollo
```bash
make dev-start      # Iniciar con logs en tiempo real
make dev-stop       # Detener modo desarrollo
make dev-logs       # Ver logs en tiempo real
```

## 🔧 Ejemplos Prácticos

### Escenario 1: Desarrollo Diario
```bash
# Llegar al trabajo
make start          # Iniciar el proyecto
make status         # Verificar que todo esté bien
make psql           # Conectar a la BD para trabajar

# Durante el día
make logs           # Ver logs si hay problemas
make update         # Aplicar nuevos cambios de Liquibase

# Al final del día
make stop           # Detener el proyecto
```

### Escenario 2: Agregar Nuevos Cambios
```bash
# 1. Crear nuevo changelog
# (editar archivo en liquibase/changelog/changes/)

# 2. Validar cambios
make validate

# 3. Ver SQL que se generará
make update-sql

# 4. Aplicar cambios
make update

# 5. Verificar estado
make status-liquibase
```

### Escenario 3: Rollback
```bash
# Si necesitas hacer rollback
make rollback VERSION=1.0.0

# Verificar estado después del rollback
make status-liquibase
```

### Escenario 4: Backup y Restore
```bash
# Crear backup antes de cambios importantes
make backup

# Si algo sale mal, restaurar
make restore BACKUP_FILE=backup_20231201_120000.sql
```

### Escenario 5: Reset Completo
```bash
# Si necesitas empezar de nuevo
make reset          # Limpia todo y reinicia
```

## 🐛 Troubleshooting

### Problema: Docker no está corriendo
```bash
make check-docker   # Verificar si Docker está corriendo
```

### Problema: Archivo .env no existe
```bash
make check-env      # Verificar si .env existe
make setup          # Crear .env si no existe
```

### Problema: Base de datos no responde
```bash
make status         # Ver estado de contenedores
make logs postgres  # Ver logs de PostgreSQL
make restart        # Reiniciar todo
```

### Problema: Liquibase falla
```bash
make validate       # Validar changelog
make status-liquibase # Ver estado de Liquibase
make logs           # Ver logs de errores
```

## 📊 Monitoreo

### Ver Estado Completo
```bash
make status         # Estado de contenedores y BD
```

### Ver Logs en Tiempo Real
```bash
make dev-logs       # Logs en tiempo real
```

### Información de Conexión
```bash
make db-info        # Datos de conexión
```

## 🔄 Flujo de Trabajo Típico

### Para Desarrolladores
1. `make start` - Iniciar el proyecto
2. `make status` - Verificar estado
3. Trabajar en la aplicación
4. `make update` - Aplicar cambios de BD si los hay
5. `make stop` - Detener al terminar

### Para DevOps
1. `make setup` - Configurar en nuevo entorno
2. `make backup` - Crear backup antes de cambios
3. `make update` - Aplicar cambios
4. `make status` - Verificar que todo funcione
5. `make docs` - Generar documentación

### Para Testing
1. `make reset` - Limpiar y empezar de nuevo
2. `make start` - Iniciar con datos limpios
3. Ejecutar tests
4. `make stop` - Limpiar después de tests

## 💡 Tips y Trucos

### Atajos Útiles
```bash
make s              # setup
make u              # update
make st             # status
make l              # logs
make p              # psql
```

### Comandos Combinados
```bash
make quick-start    # setup + start
make quick-reset    # clean + start
```

### Ver Todos los Comandos
```bash
make help           # Lista completa de comandos
```

## 🎯 Comandos Más Usados

| Comando | Descripción | Uso Frecuente |
|---------|-------------|---------------|
| `make start` | Iniciar proyecto | Diario |
| `make stop` | Detener proyecto | Diario |
| `make status` | Ver estado | Diario |
| `make psql` | Conectar a BD | Desarrollo |
| `make update` | Aplicar cambios | Después de cambios |
| `make logs` | Ver logs | Troubleshooting |
| `make backup` | Crear backup | Antes de cambios importantes |
| `make reset` | Reset completo | Cuando hay problemas |

## 🚨 Comandos de Emergencia

```bash
# Si todo está roto
make reset          # Reset completo

# Si solo Liquibase falla
make clean          # Limpiar contenedores
make start          # Reiniciar

# Si necesitas datos de respaldo
make restore BACKUP_FILE=tu_backup.sql
``` 