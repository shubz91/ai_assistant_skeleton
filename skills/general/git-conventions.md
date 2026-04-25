# Git Conventions

## Branch Naming

```
<type>/<short-description>
```

| Type | Purpose | Example |
|------|---------|---------|
| `feature/` | New functionality | `feature/user-auth` |
| `fix/` | Bug fix | `fix/login-redirect` |
| `chore/` | Maintenance, deps | `chore/update-deps` |
| `docs/` | Documentation | `docs/api-guide` |
| `refactor/` | Code restructuring | `refactor/db-layer` |

## Commit Messages

```
<type>: <short summary>

<optional body — explain why, not what>
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `docs`: Documentation only
- `test`: Adding or updating tests
- `chore`: Build process, dependencies, tooling

### Examples

```
feat: add user registration API endpoint

Implements email/password registration with validation.
Sends welcome email via the notification service.
```

```
fix: prevent duplicate transactions on double-click

Added debounce to the submit handler and server-side
idempotency check using the transaction reference ID.
```

## Pull Requests

- **Title**: Same format as commit messages (`<type>: <summary>`)
- **Description**: Include context (why), changes (what), and test plan
- **Size**: Keep PRs small — under 400 lines changed when possible
- **One concern per PR**: Don't mix a bug fix with a refactor

## Rules

1. Never push directly to `main` — always use pull requests
2. Squash merge feature branches to keep main history clean
3. Delete branches after merge
4. Rebase feature branches on main before merging (avoid merge commits)
