---
name: local-postgres
description: Explore and query local PostgreSQL databases. Use when user mentions psql, postgres, or wants to list tables, describe schema, explore data, or run queries against a local database.
color: blue
---

# Local Postgres

Explore and query local PostgreSQL databases.

## Connection

Resolve connection details in this order:

1. **POSTGRES_URL provided in chat** - The user may provide a `POSTGRES_URL` (or any postgres:// / postgresql:// connection string) directly in the conversation. If so, parse host, user, password, database, and port from it and use those values. This takes highest priority.
2. **DATABASE_URL** (Prisma standard) - Parse host, user, password, database, port from connection string
3. **Individual vars**: `POSTGRES_HOST`/`PGHOST`, `POSTGRES_USER`/`PGUSER`, `POSTGRES_PASSWORD`/`PGPASSWORD`, `POSTGRES_DB`/`PGDATABASE`, `POSTGRES_PORT`/`PGPORT`
4. **Defaults**: localhost, postgres user, postgres password, port 5432

### Parsing a connection URL

Given a URL like `postgresql://myuser:secret@db.example.com:5433/myapp`, extract:
- **User**: `myuser`
- **Password**: `secret`
- **Host**: `db.example.com`
- **Port**: `5433`
- **Database**: `myapp`

The format is: `postgresql://<user>:<password>@<host>:<port>/<database>`

If no port is specified, default to `5432`. If no user/password, default to `postgres`/`postgres`.

### Defaults

When no URL or env vars are available, use: host=`localhost`, port=`5432`, user=`postgres`, password=`postgres`.

**Cache:** `~/.ai/cache/<project-name>/postgres.json`
- Check cache first before any discovery
- Write to cache after successful discovery
- Project name = current directory or worktree name

## Commands

**No args - interactive exploration:**
```
/local-postgres
```
Lists databases, helps pick one, shows tables.

**With query:**
```
/local-postgres SELECT * FROM users LIMIT 5
```
Runs the query directly.

**With table name:**
```
/local-postgres users
```
Describes the table and shows sample rows.

**Rediscover (clear cache and re-run discovery):**
```
/local-postgres discover
```
Clears cached database, runs discovery again, updates cache.

## Workflows

### Cache Operations
```bash
# Get project name (directory or worktree name)
PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")

# Read cache
cat ~/.ai/cache/$PROJECT_NAME/postgres.json 2>/dev/null

# Write cache (after discovery)
mkdir -p ~/.ai/cache/$PROJECT_NAME
echo '{"database": "<db>", "discovered_at": "'$(date -I)'"}' > ~/.ai/cache/$PROJECT_NAME/postgres.json
```

### Exploration (no args)
1. Run `\l` to list databases
2. If database not yet determined, help user pick one (or use discovery)
3. Run `\dt` to list tables
4. Offer to describe or sample any table

### Describe Table
```bash
PGPASSWORD="$PASSWORD" psql -h "$HOST" -p "$PORT" -U "$USER" -d <db> -c "\d <table>"
```
Then show 5 sample rows.

### Quick Queries
For simple lookups, suggest useful queries:
- `SELECT COUNT(*) FROM <table>`
- `SELECT * FROM <table> ORDER BY created_at DESC LIMIT 10`
- `SELECT column_name, data_type FROM information_schema.columns WHERE table_name = '<table>'`

### Find Foreign Keys
```sql
SELECT
    tc.table_name, kcu.column_name,
    ccu.table_name AS foreign_table,
    ccu.column_name AS foreign_column
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_name = '<table>';
```

## Tips
- Use `-x` for wide tables (one column per line)
- Use `-t` when you need clean output for further processing
- Wrap complex queries in `$$ $$` if they contain quotes
