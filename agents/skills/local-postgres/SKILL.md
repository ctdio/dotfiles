---
name: local-postgres
description: Explore and query local PostgreSQL databases. Use for listing tables, describing schema, exploring data, and running queries.
color: blue
---

# Local Postgres

Explore and query local PostgreSQL databases.

## Connection

Use the connection defaults from the postgres prompt (localhost, postgres user, postgres password).

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
PGPASSWORD=postgres psql -h localhost -U postgres -d <db> -c "\d <table>"
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
