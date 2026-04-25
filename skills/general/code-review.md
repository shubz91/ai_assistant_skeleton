# Code Review Standards

## PR Checklist

Before requesting review, ensure:

- [ ] Code compiles/runs without errors
- [ ] Tests pass (existing and new)
- [ ] No hardcoded secrets, credentials, or sensitive data
- [ ] Changes are scoped to the stated purpose (no unrelated changes)
- [ ] New dependencies are justified and documented

## Reviewer Checklist

When reviewing a PR:

- [ ] **Correctness**: Does the code do what it claims?
- [ ] **Security**: Any injection risks, auth bypasses, or data leaks?
- [ ] **Performance**: Any N+1 queries, unbounded loops, or missing pagination?
- [ ] **Readability**: Can a new team member understand this without explanation?
- [ ] **Error handling**: Are failures handled gracefully?
- [ ] **Testing**: Are edge cases covered?

## Review Etiquette

1. **Be specific**: "This query could return unbounded results — add LIMIT" > "Fix the query"
2. **Explain why**: Include reasoning, not just what to change
3. **Distinguish severity**: Use prefixes:
   - `blocker:` Must fix before merge
   - `suggestion:` Improvement, not required
   - `question:` Seeking understanding, not requesting change
4. **Respond promptly**: Review within 24 hours of request

## What AI Assistants Should Flag

When an AI is reviewing code or generating PRs, it should specifically check for:

1. Credentials or secrets in code
2. SQL injection or command injection risks
3. Missing input validation on external data
4. Database queries without limits or pagination
5. Missing error handling on I/O operations
