# Backup File Merge

## When This Applies

After running `init.sh` on a project that was previously set up, backup files (`.bak`) may exist:
- `CLAUDE.md.bak` — previous CLAUDE.md with user-added project context
- `.ai/manifest.yaml.bak` — previous manifest with pinned skill versions

These are created when init.sh regenerates files, preserving the user's customizations.

## Detection

At conversation start, check for backup files:

```bash
find . -maxdepth 2 -name "*.bak" -path "./.ai/*" -o -name "CLAUDE.md.bak" 2>/dev/null
```

If found, inform the user and offer to merge.

## Merge Workflow

### CLAUDE.md.bak
1. Read both `CLAUDE.md` (new) and `CLAUDE.md.bak` (old)
2. Identify sections the user added to the old file (anything not in the template)
3. Show the user what custom sections exist in the backup
4. Offer to append them to the appropriate place in the new CLAUDE.md
5. After successful merge, delete the `.bak` file

### manifest.yaml.bak
1. Compare skill versions between old and new manifest
2. If the old manifest had custom entries or pinned versions, report them
3. The new manifest reflects the latest skill selection — usually no merge needed
4. Delete the `.bak` file after review

## Example Interaction

```
Agent: I found CLAUDE.md.bak from a previous installation. It contains these
       custom sections not in the current CLAUDE.md:

       - "## Project-Specific Context" (15 lines)
       - "## API Conventions" (8 lines)

       Would you like me to merge these into the current CLAUDE.md?
```

## Important
- Never silently merge — always show what will change
- Preserve the user's formatting and wording exactly
- If in doubt, append to the end of CLAUDE.md rather than trying to interleave
