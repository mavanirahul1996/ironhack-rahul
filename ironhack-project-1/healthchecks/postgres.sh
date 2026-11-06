
#!/bin/sh
set -e

host="$(hostname -i | awk '{print $1}')"
user="${POSTGRES_USER:-postgres}"
db="${POSTGRES_DB:-postgres}"

export PGPASSWORD="${POSTGRES_PASSWORD:-}"

pg_isready --host="$host" --username="$user" --dbname="$db"
