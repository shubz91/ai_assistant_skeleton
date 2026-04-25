# Deployment Skill

> Version: 0.1.0 | This is a summary — read detail files only when needed for a task.

This project uses Docker containers deployed via a CI/CD pipeline. Supports self-hosted
web services and scheduled cron jobs.

## Detail Files (read on demand)

- [base-path.md](base-path.md) — Framework-specific base path setup for apps served under a sub-path

## Key Rules

1. Every project needs a `Dockerfile`, CI/CD workflow file, and deploy config
2. Docker images are pushed to your container registry
3. Secrets use the `APP_` prefix convention — `APP_DATABASE_URL` → `DATABASE_URL` in the container
4. Push to `main` deploys to production. Push to `staging` deploys to staging
5. Production pipeline includes security scanning; staging may skip tests and scanning
6. **Cron jobs running more than once a day** must use a deploy config cron field, NOT a CI/CD schedule trigger (which spawns a full CI runner each time)
7. **App types**: web-only (port), cron-only (crons), or combined (both)
8. **Public static sites** (marketing pages, docs) should use a CDN/static hosting — no Docker, no server

## Before Generating Deploy Config — MUST ASK the user

1. **Hosting**: Is this a public static site (CDN/static hosting) or a server app (container)?
2. **App type** (server only): web service, cron job only, or both?
3. **Port** (web services only): what port does the app listen on?
4. **Path** (web services only): custom URL path, or default?
5. **Access**: public internet, or internal/VPN-only?
6. **Cron jobs**: schedule and command per task. More than once/day → use deploy config crons
7. **Test command**: e.g., `npm test`, `pytest`. If unsure, omit
8. **Environment variables**: which secrets? Use `APP_` prefix convention

Do NOT generate deploy config without confirming hosting type, port, and access with the user.

> **To customize**: Update this skill with your actual CI/CD platform details (GitHub Actions,
> GitLab CI, Jenkins, etc.), container registry URL, and deployment platform specifics.
