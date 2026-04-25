# Database Naming Conventions

## Tables

| Rule | Example |
|------|---------|
| Use `snake_case` | `market_data`, `trade_history` |
| Plural names for collections | `users`, `orders`, `transactions` |
| Prefix with domain for shared databases | `market_prices`, `economic_indicators` |
| No abbreviations unless universally understood | `transactions` not `txns` |

## Columns

| Rule | Example |
|------|---------|
| Use `snake_case` | `created_at`, `user_id`, `total_amount` |
| Foreign keys: `<referenced_table_singular>_id` | `user_id`, `order_id` |
| Timestamps: `<action>_at` | `created_at`, `updated_at`, `deleted_at` |
| Date columns: `date` or `<context>_date` | `date`, `trade_date`, `expiry_date` |
| Booleans: `is_<adjective>` or `has_<noun>` | `is_active`, `has_premium` |
| Amounts: include unit or currency suffix | `amount_usd`, `price_inr`, `quantity` |

## Indexes

| Rule | Example |
|------|---------|
| MySQL: `idx_<table>_<columns>` | `idx_users_email` |
| Unique: `uniq_<table>_<columns>` | `uniq_users_email` |

## MySQL-Specific

- Use `BIGINT AUTO_INCREMENT` for primary keys
- Always include `NOT NULL` where applicable
- Use `DATETIME` for timestamps
- Use `DECIMAL(precision, scale)` for financial amounts — never `FLOAT`
- Use `VARCHAR(n)` with appropriate length, not `TEXT` unless truly unbounded
- Add `created_at DATETIME DEFAULT CURRENT_TIMESTAMP` to all tables

## ClickHouse-Specific

- Use `ReplacingMergeTree` as default engine for deduplication support
- Use `MergeTree` when dedup is not needed and insert performance matters
- Partition by date/month for time-series data: `PARTITION BY toYYYYMM(date)`
- Order by the most common query filter: `ORDER BY (symbol, date)` for market data
- Use `LowCardinality(String)` for columns with few distinct values
- Use `DateTime` for timestamps, `Date` for date-only columns
- Use `Float64` for prices/amounts in analytics contexts
