# Updating Skills

## When the User Asks to Update

When the user says "update skills", "pull latest skills", "upgrade skill library", or similar:

## Step-by-Step Process

### 1. Pull Latest

Run git pull in the skill library directory:

```bash
cd .ai/lib && git pull origin main && cd -
```

If this fails (e.g., local changes in `.ai/lib/`):
```bash
cd .ai/lib && git fetch origin main && git reset --hard origin/main && cd -
```

### 2. Run Migration Check

After pulling, run the migration checker:

```bash
bash .ai/lib/migrate.sh
```

This will:
- Compare versions in `.ai/manifest.yaml` against latest `meta.yaml` files
- Report which skills have updates
- Show breaking changes with migration notes
- Save detailed migration info to `.ai/agent-execution/migration-prompt.txt`

### 3. If Migrations Needed

Read the migration prompt and apply changes:

1. Read `.ai/agent-execution/migration-prompt.txt`
2. For each skill with breaking changes:
   - Read the skill's `CHANGELOG.md` for full context
   - Read the `breaking_changes` section in `meta.yaml` for migration notes
   - Apply the migration notes to the consuming project
3. Update `.ai/manifest.yaml` with new versions after migration is complete

### 4. If No Migrations

If all skills are up to date:
- Confirm to the user that skills are current
- No further action needed

## Updating the Manifest

After successful migration, update the version in `.ai/manifest.yaml` for each migrated skill to match the latest version in `meta.yaml`.

---

## Pushing Changes Back to the Skill Library

When project work changes conventions that should be shared (new DB schemas, updated deployment patterns, etc.), push changes to `.ai/lib/` directly to main.

### Workflow

```bash
cd .ai/lib

# Stage and commit
git add -A
git commit -m "feat(<skill>): <description>"

# Push to main
git push origin main
cd -
```

### Important
- Always bump `version` in `meta.yaml` and add a CHANGELOG entry
- Add `breaking_changes` entry if the change affects existing projects
- Other projects pull the update via `migrate.sh`

---

## Example Interactions

### Pulling Updates
```
User: update skills

Agent: I'll pull the latest skill library and check for updates.

       [runs git pull]
       [runs migrate.sh]

       Results:
       - general: v0.1.0 (up to date)
       - deployment: v0.1.0 → v0.2.0 (update available)
         Breaking change: deploy config schema changed
       - database: v0.1.0 (up to date)

       The deployment skill has a breaking change. I'll scan your project for
       deploy config files and update the schema. Shall I proceed?
```

### Pushing Updates
```
User: I added a new table, update the database skill

Agent: I've updated the schema docs and bumped the database skill version.
       Pushed to main.

       Other projects will pick up the change on next `migrate.sh` run.
```
