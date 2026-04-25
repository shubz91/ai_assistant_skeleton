# Library Ops Skill

> Version: 0.1.0 | This is a summary — read detail files only when needed for a task.

Handles skill library maintenance: updating skills, merging backup files, and running migrations.

## Detail Files (read on demand)
- [backup-merge.md](backup-merge.md) — Detect and merge `.bak` files created during init
- [update-skills.md](update-skills.md) — Pull latest skills and run migration checks

## Key Rules
1. **Never overwrite user files** — `.bak` files exist because the user may have custom edits
2. **Always show diffs** — when merging backups, show what changed before applying
3. **Migration is advisory** — report what needs to change, let the user confirm
4. **Proactive detection** — check for `.bak` files at conversation start and offer to help
