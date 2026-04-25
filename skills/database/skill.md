# Database Skill

> Version: 0.1.0 | This is a summary — read detail files only when needed for a task.

This project uses two databases: **MySQL** (application data) and **ClickHouse** (analytics/time-series).
Read-only credentials are available for planning and testing. Production writes use separate
credentials via env vars injected by the deployment pipeline.

## Detail Files (read on demand)
- [credentials.md](credentials.md) — Read-only vs write credentials, env var patterns, .env setup
- [architecture.md](architecture.md) — Data reuse, ingestion cron patterns, cold start handling
- [naming-conventions.md](naming-conventions.md) — Table, column, index naming rules
- [schemas/](schemas/) — Per-database schema docs (MySQL and ClickHouse)

## Key Rules
1. **Read-only for planning/testing** — use read credentials to explore tables. Never write with read creds
2. **Write via env vars** — production scripts use separate credentials from secrets (`APP_` prefix), never the read-only ones
3. **Prefer existing tables** — check if data already exists before creating new tables. Read schemas/ first
4. **Generic data → shared DB** — store reusable data in a logical shared database, not per-project, unless user overrides
5. **Incremental ingestion** — crons should fill data from last available date in table. For cold start, ask user for default start date
6. **Update this skill** — when creating new tables or databases, update schemas/ docs, bump skill version, and push with a PR

> **To customize**: Update credentials.md with your actual database hosts and credentials (use dummy values in development), and populate schemas/ with your actual table documentation.
