# Migration System

## How It Works

The migration system is **AI-driven** — there is no custom migration tooling. Instead, skill authors write migration instructions that AI assistants can follow.

### For Skill Authors

When you make a breaking change to a skill:

1. Bump the `version` in `meta.yaml`
2. Add a `breaking_changes` entry:

```yaml
breaking_changes:
  - version: "0.2.0"
    summary: "Changed table naming from camelCase to snake_case"
    migration_notes: |
      Scan the consuming project for any database table references
      using camelCase (e.g., marketData, tradeHistory) and rename
      them to snake_case (market_data, trade_history). Also update
      any SQL migration files, ORM models, and query strings.
```

The `migration_notes` field is the key — it's a prompt for the AI assistant. Write it as clear instructions that tell the AI:
- **What to look for** in the consuming project
- **How to fix it** (specific patterns, replacements, or approach)
- **What to be careful about** (edge cases, things not to change)

### For Consuming Projects

1. Pull the latest skill library: `cd .ai/lib && git pull origin main`
2. Run the migration check: `bash .ai/lib/migrate.sh`
3. If updates are found, ask your AI assistant to migrate:
   - The AI reads the `breaking_changes` migration notes
   - Scans your codebase for affected patterns
   - Generates the code changes
   - Updates `.ai/manifest.yaml` with new versions
4. Review the changes and commit

### Writing Good Migration Notes

Good migration notes are:
- **Specific**: "Rename `camelCase` table references to `snake_case`" not "Update naming"
- **Searchable**: Include the patterns to look for
- **Actionable**: Include the replacement pattern or approach
- **Scoped**: Mention which file types to check (e.g., "SQL files, ORM models, migration scripts")

### Example Flow

```
# Skill author updates database skill from 0.1.0 to 0.2.0
# with a breaking change to naming conventions

# Developer in consuming project:
cd .ai/lib && git pull origin main && cd ../..
bash .ai/lib/migrate.sh

# Output shows:
# database: v0.1.0 → v0.2.0 (update available)
# Breaking: Changed table naming from camelCase to snake_case

# Developer asks AI assistant:
# "Migrate skills to latest"

# AI reads migration notes, scans code, generates changes,
# updates manifest, developer reviews and commits.
```
