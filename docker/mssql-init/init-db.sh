#!/bin/bash
# Purpose:
#   Entry-point script for the `mssql-init` helper container defined in `compose.yaml`.
#
# What it does:
#   1. Detects which `sqlcmd` binary is available inside the container.
#   2. Waits until the main `mssql` service accepts connections on the internal SQL port.
#   3. Runs `/scripts/init.sql` with values from the Docker environment to create the
#      default database, login, user, and permissions used by this stack.
#
# Where it is used:
#   Mounted from `docker/mssql-init/` into the `mssql-init` container and executed via:
#   entrypoint: ["/bin/bash", "/scripts/init-db.sh"]
#
# Required environment variables:
#   MSSQL_SA_PASSWORD, MSSQL_DATABASE, MSSQL_USER, MSSQL_PASSWORD, MSSQL_PORT(optional)
set -e

if [ -x /opt/mssql-tools18/bin/sqlcmd ]; then
  SQLCMD=/opt/mssql-tools18/bin/sqlcmd
elif [ -x /opt/mssql-tools/bin/sqlcmd ]; then
  SQLCMD=/opt/mssql-tools/bin/sqlcmd
else
  echo "sqlcmd not found in container"
  exit 1
fi

until "$SQLCMD" -S mssql,"${MSSQL_PORT:-1433}" -U sa -P "$MSSQL_SA_PASSWORD" -Q "SELECT 1" >/dev/null 2>&1; do
  echo "Waiting for SQL Server to accept connections..."
  sleep 5
done

"$SQLCMD" \
  -S mssql,"${MSSQL_PORT:-1433}" \
  -U sa \
  -P "$MSSQL_SA_PASSWORD" \
  -v DB_NAME="$MSSQL_DATABASE" DB_LOGIN="$MSSQL_USER" DB_PASSWORD="$MSSQL_PASSWORD" \
  -i /scripts/init.sql

echo "Database initialization completed."