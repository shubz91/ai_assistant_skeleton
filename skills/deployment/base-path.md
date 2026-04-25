# Base Path Configuration

Apps served behind a reverse proxy under a sub-path (e.g., `https://apps.example.com/<path>/`)
must be base-path-aware. Hardcoding `/` as root will break routing, assets, and API calls.

## Framework-Specific Setup

| Framework | How to configure base path |
|-----------|--------------------------|
| **Express/Node** | Mount router under `/<path>`: `app.use('/<path>', router)` |
| **React (Vite)** | Set `base: '/<path>/'` in `vite.config.ts` |
| **React (CRA)** | Set `"homepage": "/<path>"` in `package.json` |
| **Next.js** | Set `basePath: '/<path>'` in `next.config.js` |
| **Flask** | Use `APPLICATION_ROOT = '/<path>'` or `Blueprint` with url_prefix |
| **Django** | Set `FORCE_SCRIPT_NAME = '/<path>'` and `STATIC_URL = '/<path>/static/'` |
| **FastAPI** | Set `root_path='/<path>'` in the app constructor |
| **Static (nginx)** | Ensure all asset hrefs are relative or prefixed with `/<path>/` |

## Rules for Generated Code

1. Use relative URLs for assets (`./style.css` not `/style.css`)
2. Read the base path from an environment variable or config, don't hardcode it
3. Ensure redirects include the base path
4. Ensure API fetch calls use the base path prefix
5. Test locally with the base path to catch issues before deployment
