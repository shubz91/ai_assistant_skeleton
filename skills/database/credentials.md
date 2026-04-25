# Database Credentials

## Two Credential Tiers

| Tier | Purpose | How Provided | Can Write? |
|------|---------|-------------|------------|
| **Read-only** | Planning, testing, exploring schemas, dashboards | Available to AI agent directly | No |
| **Write (production)** | Ingestion pipelines, app writes, migrations | Secrets → env vars via `APP_` prefix | Yes |

## Read-Only Credentials

These are safe to use for:
- Exploring table structures and data
- Testing queries during development
- Powering read-only dashboards
- Validating data after pipeline runs

> The AI agent has read-only access for planning. Never use these for production writes.

### MySQL (read-only)
| Field | Value |
|-------|-------|
| Host | `localhost` |
| Port | `3306` |
| User | `readonly_user` |
| Password | `readonly_password` |
| Databases | `app_db`, `analytics` |

> **Replace with your actual read-only credentials.**

### ClickHouse (read-only)
| Field | Value |
|-------|-------|
| Host | `localhost` |
| Port (HTTP) | `8123` |
| Port (Native) | `9000` |
| User | `readonly_user` |
| Password | `readonly_password` |
| Database | `analytics` |

> **Replace with your actual read-only credentials.**

## Write Credentials (Production)

Write credentials are **never hardcoded** and never shared with the AI agent.
They flow through the deployment pipeline:

1. Added as secrets with `APP_` prefix (e.g., `APP_MYSQL_WRITE_URL`)
2. Automatically injected into the container as env vars (e.g., `MYSQL_WRITE_URL`)
3. Application code reads from `os.environ` / `process.env`

## Environment Variable Naming

| Variable | Purpose |
|----------|---------|
| `MYSQL_HOST` | MySQL connection host |
| `MYSQL_PORT` | MySQL connection port |
| `MYSQL_USER` | MySQL username |
| `MYSQL_PASSWORD` | MySQL password |
| `MYSQL_DATABASE` | MySQL database name |
| `CLICKHOUSE_HOST` | ClickHouse connection host |
| `CLICKHOUSE_PORT` | ClickHouse connection port (HTTP: 8123, Native: 9000) |
| `CLICKHOUSE_USER` | ClickHouse username |
| `CLICKHOUSE_PASSWORD` | ClickHouse password |
| `CLICKHOUSE_DATABASE` | ClickHouse database name |

## Local Development

Create a `.env` file (add to `.gitignore`!):

```bash
# .env — DO NOT COMMIT
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_USER=myuser
MYSQL_PASSWORD=mypass
MYSQL_DATABASE=mydb

CLICKHOUSE_HOST=localhost
CLICKHOUSE_PORT=8123
CLICKHOUSE_USER=default
CLICKHOUSE_PASSWORD=
CLICKHOUSE_DATABASE=default
```

Load via `python-dotenv`, `dotenv` for Node, etc.

## Connection Patterns

### MySQL
```python
# Python (SQLAlchemy)
mysql://user:pass@host:3306/dbname
```

```javascript
// Node (mysql2)
{ host, port, user, password, database }
```

### ClickHouse
```python
# Python (clickhouse-connect)
clickhouse://user:pass@host:8123/dbname   # HTTP interface
```
