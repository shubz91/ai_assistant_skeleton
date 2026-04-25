# Orchestrator Agent — Workflow

> This file defines the mandatory workflow for non-trivial tasks.
> Follow these stages in order. Do not skip stages unless the user explicitly asks.

## When to Use This Workflow

Use for any task that involves:
- Creating or modifying more than 2-3 files
- Setting up infrastructure (DB, CI/CD, deployment)
- New features or significant changes
- Data pipeline or dashboard development

Skip for trivial tasks (typo fixes, single-line changes, quick questions).

---

## Stage 1: DISCUSS

**Goal**: Understand the requirement and align with the user.

1. Read the relevant skill files from `.ai/lib/skills/` for context
2. Ask clarifying questions — don't assume
3. Identify constraints, dependencies, and affected systems
4. Summarize your understanding back to the user
5. Get explicit confirmation before proceeding

**Output**: Confirmed understanding of what needs to be done and why.

---

## Stage 2: PLAN

**Goal**: Create a concrete implementation plan.

1. Write the plan to `.ai/agent-execution/current-plan.md`
2. Plan should include:
   - **Context**: Why this change is needed
   - **Approach**: How you'll implement it
   - **Files to create/modify**: List with brief descriptions
   - **Dependencies**: What must exist or be done first
   - **Risks**: Anything that could go wrong
   - **Skill references**: Which skill files informed the plan
3. If the plan changes conventions covered by a skill (deploy config schema, CI/CD workflows, database schemas, etc.):
   - Note which skill(s) in `.ai/lib/skills/` need updating
   - Include the skill documentation + CHANGELOG update as a task
4. Present plan to user for review
5. Get explicit approval before executing

**Output**: Approved plan at `.ai/agent-execution/current-plan.md`

---

## Stage 3: TASKS

**Goal**: Break the plan into trackable tasks.

1. Write tasks to `.ai/agent-execution/tasks.md`
2. Each task should be:
   - Small enough to complete in one step
   - Independently verifiable
   - Ordered by dependency
3. Format:

```markdown
## Tasks

- [ ] Task 1: Description
- [ ] Task 2: Description
- [x] Task 3: Description (completed)
- [ ] ...
```

4. Include a final task for verification/testing

**Output**: Task list at `.ai/agent-execution/tasks.md`

---

## Stage 4: EXECUTE

**Goal**: Implement tasks one by one with progress tracking.

For each task:
1. Mark it as in-progress in `tasks.md`
2. Implement the change
3. Verify it works (run tests, check output, etc.)
4. Mark as complete in `tasks.md`
5. If a task changes conventions covered by **any** skill (deploy config schema, CI/CD workflows, database schemas, etc.):
   - Update the relevant docs in `.ai/lib/skills/<skill>/`
   - Bump the skill version in `.ai/lib/skills/<skill>/meta.yaml`
   - Add a CHANGELOG entry in `.ai/lib/skills/<skill>/CHANGELOG.md`
   - Note the breaking change if applicable
   - Commit and push these changes to main (see "Updating Skills from a Project" below)

**Resume capability**: If the conversation is interrupted:
- Read `.ai/agent-execution/current-plan.md` for the plan
- Read `.ai/agent-execution/tasks.md` for progress
- Continue from the first unchecked task

**Output**: Completed implementation with all tasks checked off.

---

## Stage 5: REVIEW

**Goal**: Verify everything works and clean up.

1. Run any applicable tests
2. Review changes against the original plan
3. Check that skill library updates (if any) have been pushed to main
4. Update `.ai/manifest.yaml` if skill versions changed
5. Present summary to user

---

## File Locations

| File | Purpose | Tracked in git? |
|------|---------|----------------|
| `.ai/agent-execution/current-plan.md` | Active plan | No (gitignored) |
| `.ai/agent-execution/tasks.md` | Task progress | No (gitignored) |
| `.ai/agent-execution/orchestrator.md` | This file | No (gitignored) |
| `.ai/manifest.yaml` | Skill versions | Yes |
| `.ai/lib/skills/*/` | Skill library | No (gitignored clone) |

## Updating Skills from a Project

When your work changes conventions that should apply to all projects:

1. Make the change in `.ai/lib/skills/<skill>/`
2. Bump version in `meta.yaml`
3. Add CHANGELOG entry
4. Add `breaking_changes` entry if it affects existing code
5. Commit and push directly to main:
   ```bash
   cd .ai/lib
   git add -A
   git commit -m "feat(<skill>): <description>"
   git push origin main
   cd -
   ```
6. Other projects pull the update via `migrate.sh`
