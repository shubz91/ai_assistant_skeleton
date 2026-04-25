# Coding Guidelines

## Architecture

### Single Container Principle
Default to **one container per deployment**. Do not split into multiple services (e.g., separate API + worker + frontend containers) unless the user explicitly requests it. Keep it simple — a single process handling the app is easier to deploy, debug, and maintain.

If multi-container is genuinely needed, discuss the trade-offs with the user first.

### Dashboard Architecture
Dashboards should **never query external APIs or heavy data sources directly from the frontend**. Instead:

1. **Create a cron job** (via your CI/CD scheduler) that pulls data on a schedule
2. **Store the results** in a persistent store (database, JSON file, or cache)
3. **Power the frontend** from that stored data

This ensures:
- Dashboards load fast (reading from local DB, not waiting on external APIs)
- External API rate limits and outages don't break the dashboard
- Data is available for historical comparison
- Multiple users don't each trigger expensive queries

**Pattern:**
```
Scheduled cron → fetch data → write to DB
Frontend → read from DB → render dashboard
```

## Testing & Validation

### Visual Verification
Testing and validation should include **checking output on screen**. Don't rely solely on unit tests — verify that the rendered output looks correct.

### Validation Checklist
When completing a feature or fix:
1. **Unit/integration tests** pass
2. **Visual check** — verify the output renders correctly on screen
3. **Base path** — confirm the app works at its deployed path (not just `/`)
4. **Data flow** — for dashboards, verify the cron populates data and frontend reads it correctly
