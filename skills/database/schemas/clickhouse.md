# ClickHouse Schema Documentation

> This file is updated as new tables are created. Check here before creating new tables.

**Server:** localhost:8123 | **Database:** analytics

> **Replace with your actual server address and read-only credentials.**

## Databases

| Database | Tables | Description |
|----------|--------|-------------|
| analytics | [Update as tables are added] | Time-series and aggregated analytics data |
| default | 0 | Empty |

---

## Example Table: `analytics.events_daily`

**Purpose:** [Example placeholder — replace with your actual ClickHouse tables]
**Engine:** ReplacingMergeTree
**Order By:** `(event_type, date)`
**Partition:** `toYYYYMM(date)` (monthly partitions)
**Rows:** 0

| Column | Type | Description |
|--------|------|-------------|
| event_type | LowCardinality(String) | Type of event |
| date | Date | Event date |
| count | UInt64 | Number of events |
| unique_users | UInt64 | Distinct users |
| updated_at | DateTime | Insert/update timestamp |

---

## Example Table: `analytics.metrics_hourly`

**Purpose:** [Example placeholder — replace with your actual ClickHouse tables]
**Engine:** MergeTree
**Order By:** `(metric_name, timestamp)`
**Partition:** `toYYYYMMDD(timestamp)` (daily partitions)
**Rows:** 0

| Column | Type | Description |
|--------|------|-------------|
| metric_name | LowCardinality(String) | Metric identifier |
| timestamp | DateTime | Measurement timestamp |
| value | Float64 | Metric value |
| labels | String | JSON-encoded labels |

---

> **Instructions**: As you create new ClickHouse tables, document them here.
> Include: engine, partition key, order by key, and column definitions.
> ClickHouse query performance depends heavily on these — always document them.
