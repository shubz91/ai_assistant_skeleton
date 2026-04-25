# MySQL Schema Documentation

> This file is updated as new tables are created. Check here before creating new tables.

**Server:** localhost:3306 | **User (read-only):** readonly_user

> **Replace with your actual server address and read-only credentials.**

## Databases

| Database | Tables | Domain |
|----------|--------|--------|
| app_db | [Update as tables are added] | Application data |
| analytics | [Update as tables are added] | Analytics and reporting |

---

## `app_db` — Application Database

> Populate this section with your actual table documentation as you create tables.

### Example: `app_db.users`
**Purpose:** [Example placeholder — replace with your actual tables]

| Column | Type | Description |
|--------|------|-------------|
| id | bigint, PK, auto_increment | Unique user identifier |
| email | varchar(255), UNIQUE | User email address |
| name | varchar(255) | Display name |
| created_at | datetime | Account creation timestamp |
| updated_at | datetime | Last update timestamp |

### Example: `app_db.events`
**Purpose:** [Example placeholder — replace with your actual tables]

| Column | Type | Description |
|--------|------|-------------|
| id | bigint, PK, auto_increment | |
| user_id | bigint, FK → users.id | Associated user |
| event_type | varchar(100) | Type of event |
| payload | json | Event data |
| created_at | datetime | Event timestamp |

---

## `analytics` — Analytics Database

> Populate this section with your actual analytics table documentation.

### Example: `analytics.daily_metrics`
**Purpose:** [Example placeholder — replace with your actual tables]

| Column | Type | Description |
|--------|------|-------------|
| date | date | Metric date |
| metric_name | varchar(255) | Name of the metric |
| value | decimal(18, 4) | Metric value |
| created_at | datetime | Insert timestamp |

---

> **Instructions**: As you create new tables, add them to the appropriate database section above.
> Include: table name, purpose, and column definitions. This keeps the AI aware of what data exists.
