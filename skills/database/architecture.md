# Database Architecture

## Infrastructure

| Database | Engine | Purpose | Access |
|----------|--------|---------|--------|
| MySQL | MySQL | Application data, user state, configuration | Read for dashboards, write for apps |
| ClickHouse | ClickHouse | Analytics, time-series, aggregations | Read for dashboards, write for ingestion pipelines |

## Data Reuse Principle

**Always prefer existing tables over creating new ones.**

Before creating a new table:
1. Read the schema docs in [schemas/](schemas/) to understand what data already exists
2. Query existing tables to check if the data you need is already available
3. If existing data covers 80%+ of your needs, extend the existing pipeline rather than creating a new one
4. Only create new tables when the data genuinely doesn't exist

### Generic Data → Shared Database

Data that could be useful across multiple projects (prices, volumes, events, metrics, etc.)
should be stored in a **logical shared database** so it's reusable.

Do NOT create per-project copies of shared data unless:
- The user explicitly requests it
- The data requires project-specific transformations that don't generalize

## Ingestion Pipeline Pattern

All data ingestion follows: **Scheduled cron → Script → Database**

### Incremental Ingestion

Pipelines must be **incremental** — they should:

1. Check the **last available date/record** in the target table
2. Fetch only data from that point onward
3. Insert/upsert the new data

```python
# Example pattern
last_date = db.query("SELECT MAX(date) FROM market_prices")
new_data = fetch_from_source(start_date=last_date)
db.insert(new_data)
```

### Cold Start

When a table is empty (first run), the pipeline needs a start date.

**MUST ASK the user**: "What should the default start date be for initial data load?"

Do not assume a start date. Different datasets have different availability windows.

```python
# Cold start pattern
last_date = db.query("SELECT MAX(date) FROM market_prices")
if last_date is None:
    last_date = DEFAULT_START_DATE  # Set by user / env var
```

### Pipeline Rules

1. **Idempotent** — safe to re-run without duplicating data (use upserts or date-based dedup)
2. **Incremental** — only fetch new data, never re-fetch everything
3. **Logged** — log start/end times, row counts, and errors
4. **Scheduled via cron** — not via always-on processes
5. **Single container** — pipeline runs as part of the app container, not a separate service

## Dashboard Data Flow

```
Scheduled cron → ingestion script → write to DB (ClickHouse/MySQL)
Frontend → read from DB → render dashboard
```

Never query external APIs directly from the frontend.

## Creating New Tables or Databases

When you create a new table or database:

1. Follow the [naming conventions](naming-conventions.md)
2. **Update this skill**: add schema documentation to `schemas/mysql.md` or `schemas/clickhouse.md`
3. Include the table name, columns, types, purpose, and any indexes
4. Bump the database skill version in `meta.yaml`
5. Add a CHANGELOG entry
