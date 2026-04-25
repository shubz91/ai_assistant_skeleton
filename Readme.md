# AI Skill Library

A shared, versioned collection of AI-assisted development guidance. Import into any project with a single command to get consistent conventions for branding, deployment, databases, and general development.

## Quick Start

From your project root:

```bash
curl -sL https://raw.githubusercontent.com/your-org/ai-skills-sample/main/install.sh | bash
```

Or override the repo URL:

```bash
curl -sL https://raw.githubusercontent.com/your-org/ai-skills-sample/main/install.sh | bash -s -- --repo <your-git-repo-url>
```

This creates:

```
your-project/
├── CLAUDE.md                  # AI assistant entry point
├── .ai/
│   ├── manifest.yaml          # Skill versions (tracked in git)
│   ├── lib/                   # This repo (git clone, gitignored)
│   └── agent-execution/       # Plans, tasks, state (gitignored)
│       └── orchestrator.md    # Enforces plan-first workflow
```

### Idempotent Re-runs

Safe to run the same command again at any time. Re-run pulls latest skills into `.ai/lib/` — your CLAUDE.md, manifest.yaml, and settings are never overwritten.

**Fresh redo** — delete `.ai/manifest.yaml` first, then re-run to get the full interactive setup again.

## Available Skills

| Skill | Description |
|-------|-------------|
| **brand** | Color palette, typography, logos, UI components |
| **deployment** | CI/CD, Docker, deploy config, env vars, platform reference |
| **database** | Credentials, schemas, naming conventions, architecture |
| **general** | Project planning, code review, testing, git conventions |
| **ai-gateway** | LLM/agent execution gateway for production apps |
| **library-ops** | Skill library maintenance — update skills, merge backups, run migrations |

## How It Works

### Token-Efficient Loading
Each skill has a concise `skill.md` (~20 lines) that's always loaded. Detail files are read only when the AI needs them for a specific task.

### Orchestrator Workflow
For non-trivial tasks, the orchestrator enforces:

1. **DISCUSS** — Understand, clarify, confirm
2. **PLAN** — Write plan, get approval
3. **TASKS** — Break into trackable items
4. **EXECUTE** — Implement with resume capability
5. **REVIEW** — Verify and present

Plans and tasks are saved to `.ai/agent-execution/` so work survives conversation interruptions.

### Skill Feedback Loop
When project work changes conventions (e.g., new DB tables, deploy config schema), the orchestrator prompts the agent to update the relevant skill in `.ai/lib/`. Changes are committed and pushed to main.

## Updating Skills

Just re-run the installer — it pulls latest into `.ai/lib/` without touching your config:

```bash
curl -sL https://raw.githubusercontent.com/your-org/ai-skills-sample/main/install.sh | bash
```

If there are breaking changes, ask your AI assistant: **"migrate skills to latest"**

## Migration

Skill authors add `breaking_changes` entries to `meta.yaml` with AI-targeted migration notes. When you upgrade, the AI reads these notes, scans your codebase, and generates the necessary changes.

Example in `skills/database/meta.yaml`:
```yaml
breaking_changes:
  - version: "0.2.0"
    summary: "Renamed tables from camelCase to snake_case"
    migration_notes: |
      Scan for camelCase table references and rename to snake_case.
```

## Contributing

### Adding a New Skill

Create `skills/<name>/` with:
- `meta.yaml` — version, description, files list
- `skill.md` — concise summary with links to detail files
- `CHANGELOG.md` — change history
- Detail files as needed

### Updating an Existing Skill

1. Edit files, bump `version` in `meta.yaml`, add CHANGELOG entry
2. For breaking changes: add `breaking_changes` entry with `migration_notes`

### meta.yaml Format

```yaml
name: skill-name
version: "X.Y.Z"
description: "One-line description"
authors:
  - "Team Name"
files:
  - skill.md
  - detail-file.md
breaking_changes:
  - version: "X.Y.Z"
    summary: "What changed"
    migration_notes: |
      AI-targeted instructions for migrating consuming projects.
```

## Repository Structure

```
ai_skills_sample/
├── Readme.md              <- You are here
├── VERSION
├── CHANGELOG.md
├── install.sh             # One-line curl installer
├── init.sh                # Interactive bootstrap
├── migrate.sh             # Migration checker
├── skills/
│   ├── brand/
│   ├── deployment/
│   ├── database/
│   ├── general/
│   ├── ai-gateway/
│   └── library-ops/
├── agent-execution/
│   └── orchestrator.md    # Workflow definition (copied to projects)
└── templates/
    ├── CLAUDE.md.tmpl
    ├── readme.md.tmpl
    └── manifest.yaml.tmpl
```

## FAQ

**Q: Do I need Claude Code?**
A: No. Skills are plain markdown. Any AI tool that reads files can use them. Use `--inline` flag for tools that don't follow file references.

**Q: Should `.ai/` be in `.gitignore`?**
A: Partially. `.ai/lib/` (the cloned skill library) and `.ai/agent-execution/` (ephemeral state) are gitignored automatically. `.ai/manifest.yaml` and `.ai/readme.md` should be tracked. The `init.sh` handles this.

**Q: Can I override skill guidance?**
A: Yes. Add project-specific instructions in CLAUDE.md. They take priority.

**Q: How do I customize this for my organization?**
A: Fork this repo, update the skill content (brand colors, DB schemas, deployment platform, etc.) to match your stack, and update the `DEFAULT_REPO` URL in `install.sh`.
