# General Skill

> Version: 0.1.0 | This is a summary — read detail files only when needed for a task.

General development conventions for planning, review, testing, and git workflows.

## Detail Files (read on demand)
- [coding-guidelines.md](coding-guidelines.md) — Architecture patterns, single container, dashboard data flow, visual testing
- [project-planning.md](project-planning.md) — Task breakdown, estimation, milestones
- [code-review.md](code-review.md) — PR checklist, reviewer checklist, etiquette
- [testing.md](testing.md) — Testing patterns for Python (pytest) and Node (vitest/jest)
- [git-conventions.md](git-conventions.md) — Branch naming, commit messages, PR format

## Key Rules
1. **Single container** — one container per deployment unless user explicitly asks otherwise
2. **Dashboard data flow** — use cron → DB → frontend, never query external APIs directly from the UI
3. **Visual verification** — always check rendered output on screen, not just unit tests
4. All code changes go through pull request review before merging
5. Follow git conventions for branch naming and commit messages
6. Write tests for new functionality — follow the patterns in testing.md
