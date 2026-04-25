# AI Gateway Skill

> Version: 0.1.0 | This is a summary — read detail files only when needed for a task.

A **Claude Code API Gateway** provides a sandboxed, stateless AI execution service
with tool access (file I/O, bash, web search, subagents). OpenAI SDK compatible.

When app code needs LLM processing or agent workflows, use the gateway —
never embed API keys directly in application code.

## Endpoints
- `POST /v1/chat/completions` — Single prompt (OpenAI-compatible)
- `POST /v1/workflow` — Multi-step agent pipeline (DAG, parallel execution)
- `GET /openapi.json` — Full OpenAPI 3.1 spec

## Gateway URL
- Default: `http://ai-gateway.internal:8000`
- Update this to your actual gateway endpoint

## Detail Files (read on demand)
- [api-reference.md](api-reference.md) — Endpoint docs, parameters, response schemas, code examples
- [workflow-patterns.md](workflow-patterns.md) — DAG patterns, parallel execution, common recipes

> **To customize**: Update the gateway URL above to your actual deployment.
> If you don't run a gateway, you can use the Anthropic API directly — see the Anthropic SDK docs.
